# find next entry in PATH for wrapper scripts
# Usage: next-in-path <program name> <current $0>
next-in-path() {
	entries=( $(which -a $1) )
	index=${entries[(ie)$2]} 
	if [[ $index -le ${#entries} ]]; then
		# found $0, use next entry
		echo $entries[$((index + 1))]
	else
		echo $entries[1]
	fi
}
