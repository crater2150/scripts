#!/bin/zsh

source ${$(realpath "$0"):h}/lib/common.zsh

typeset -A interpreter_checked
have_dependency() {
	if [[ ! $interpreter_checked[$1] ]]; then
		check "Checking for $1… "
		if which $1 &> /dev/null; then
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

get_dependencies() {
	sed -n '2{/^#dep:/{s/^#dep://;p;q}}' $1
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
else
	install_path=${install_path[2]}
fi

for prog in $@; do
	for lang in zsh ruby python amm; do
		if uses_interpreter $lang $prog; then
			have_dependency $lang || exit 1
		fi
	done
	for dep in $(get_dependencies $prog); do
		have_dependency $dep || exit 1
	done
	if [[ -e $install_path/${prog:t} && ! $force ]]; then
		warning "$prog already exists at $install_path. Skipping."
	else
		check "Installing $prog… "
		ln -fsr $prog $install_path || fail
		succeed
	fi
done
