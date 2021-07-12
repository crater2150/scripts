#!/bin/zsh

source ${$(realpath "$0"):h}/lib/common.zsh

if [[ -z $1 ]]; then
	<<-HELP
	Usage: $0 [opts] <program_names>
	Options:
	  -p, --path PATH         target directory to install into (defaults to ~/.local/bin)
	  -d, --dot, -m, --multi  create g.\$prog links, allowing multiple instances
	  -n, --no-tmux           don't launch with tmux
	HELP
	exit 1
fi

zparseopts -D -E \
	p:=install_path -path:=install_path \
	d=multi -dot=multi m=multi -multi=multi \
	n=notmux -no-tmux=notmux


do-install() {
	local wrapper=$1
	local install_path=$2
	local prefix=$3
	local prog=$4
	local target="$prefix${prog:t}"

	target="$prefix${prog:t}"
	if [[ -e $install_path/${target} ]]; then
		warning "${target} already exists at $install_path. Skipping."
	else
		check "Creating $prog link $target… "
		ln -fsr lib/$wrapper $install_path/$target || fail
		succeed
	fi
}

if [[ ! $install_path ]]; then
	install_path=$HOME/.local/bin
else
	install_path=${install_path[2]}
fi

if [[ $notmux ]]; then
	if [[ $multi ]]; then warning "Ignoring $multi, as no tmux is used"; fi
	for prog in $@; do
		do-install with-term $install_path g $prog
	done
else
	if [[ $multi ]]; then prefix='g.'; else prefix='g'; fi

	for prog in $@; do
		do-install g $install_path $prefix $prog
	done
fi
