#!/bin/zsh

source ${$(realpath "$0"):h}/lib/common.zsh

typeset -A interpreter_checked
have_dependency() {
	if [[ ! $interpreter_checked[$1] ]]; then
		check "Checking for $1… "
		for variant in ${(s.|.)1}; do
			if which $variant &> /dev/null; then
				succeed
				interpreter_checked[$1]=1
				return 0
			fi
		done
		fail "not found in path"
		return 1
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
	Usage: $0 [opts] <program_names>
	Options:
	  -p, --path PATH   target directory to install into (defaults to ~/.local/bin)
	  -f, --force       overwrite existing files in the same dir
	  -s, --skip        when installing several scripts, skip scripts with unmet
	                    dependencies instead of aborting.
	HELP
	exit 1
fi

zparseopts -D -E p:=install_path -path:=install_path f=force -force=force \
	s=skip -skip=skip

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
		if ! have_dependency $dep; then
			if [[ $skip ]]; then
				continue 2
			else
				exit 1
			fi
		fi
	done
	if [[ -e $install_path/${prog:t} && ! $force ]]; then
		warning "$prog already exists at $install_path. Skipping."
	else
		check "Installing $prog… "
		ln -fsr $prog $install_path || fail
		succeed
	fi
done
