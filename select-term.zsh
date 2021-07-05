#!/bin/zsh

zparseopts -D -E p:=install_path -path:=install_path h:=help -help:=help

if [[ $help ]]; then
	<<-HELP
	Usage: $0 [opts]

	Installs a wrapper script for the selected terminal under the name
	"x-terminal-emulator" in path. The wrapper ensures a common interface for
	setting title, class and passing commands.

	Options:
	  -p, --path PATH   target directory to install into (defaults to ~/.local/bin)
	HELP
	exit 1
fi


if [[ ! $install_path ]]; then
	install_path=$HOME/.local/bin
else
	install_path=${install_path[2]}
fi

terms=( lib/term-wrapper-* )

selected_term=$(printf "%s\n" ${terms:t} | fzf)
ln -fsr lib/$selected_term $install_path/x-terminal-emulator
