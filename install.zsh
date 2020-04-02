#!/bin/zsh

source ${$(realpath "$0"):h}/lib/common.zsh

typeset -A interpreter_checked
have_interpreter() {
	if [[ ! $interpreter_checked[$1] ]]; then
		check "Checking for $1… "
		if which ruby &> /dev/null; then
			succeed
			interpreter_checked[$1]=1
			return 0
		else
			fail "not found in path"
			return 1
		fi
	fi

}

uses_interpreter() {
	head -n 1 $2 | grep -q $1
}

if [[ -z $1 ]]; then
	<<-HELP
	Usage: $0 [-p PATH] <program_names>
	HELP
	exit 1
fi

zparseopts -D -E p:=install_path -path:=install_path f=force -force=force

if [[ ! $install_path ]]; then
	install_path=$HOME/.local/bin
fi

for prog in $@; do
	for lang in zsh ruby python; do
		if uses_interpreter $lang $prog; then
			have_interpreter $lang || exit 1
		fi
	done
	if [[ -e $install_path/${prog:t} && ! $force ]]; then
		warning "$prog already exists at $install_path. Skipping."
	else
		ln -fsr $prog $install_path
	fi
done
