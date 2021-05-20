#!/bin/zsh

source ${$(realpath "$0"):h}/lib/common.zsh

if [[ -z $1 ]]; then
	<<-HELP
	Usage: $0 [opts] <program_names>
	Options:
	  -p, --path PATH   target directory to install into (defaults to ~/.local/bin)
	  -d, --dot, -m, --multi    create g.\$prog links, allowing multiple instances
	HELP
	exit 1
fi

zparseopts -D -E p:=install_path -path:=install_path d=multi -dot=multi m=multi -multi=multi

if [[ ! $install_path ]]; then
	install_path=$HOME/.local/bin
else
	install_path=${install_path[2]}
fi

if [[ $multi ]]; then prefix='g.'; else prefix='g'; fi

for prog in $@; do
	target="$prefix${prog:t}"
	if [[ -e $install_path/${target} ]]; then
		warning "${target} already exists at $install_path. Skipping."
	else
		check "Creating $target… "
		ln -fsr lib/g $install_path/$target || fail
		succeed
	fi
done
