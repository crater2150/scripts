#!/bin/zsh
if git status --porcelain | grep -q '^A'; then
	echo 'You have uncommited but staged changes. Aborting'
	exit 1
fi
if [[ ! -e $1 ]]; then
	echo "$1 not found"
	exit 1
fi
if ! git status --porcelain -- $1 | grep -q '^\?\?'; then
	echo "$1 already in repository"
	exit 1
fi

git add $1
git commit -m "New script: $1"
