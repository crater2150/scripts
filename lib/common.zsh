autoload -Uz colors && colors

local c_fail="${fg_bold[red]}✘$reset_color"
local c_success="${fg_bold[green]}✔$reset_color"

check() {
	echo -n " ? $*"
}

result() {
	echo -n "\e[s"
	echo -n "\e[1G $1"
	echo -n "\e[u"
	shift
	echo " $*"
}

fail() { result $c_fail $@ }
succeed() { result $c_success $@ }
error() { echo -n "  "; fail $@ }

depend() {
	local missing
	local i

	for i in "$@"; do
		type "$i" &>/dev/null || {
			echo >&2 " $c_fail Missing dependency: $i. Please install it"
			missing=1
		}
	done
	[[ -n "$missing" ]] && exit 1
}

urlencode() {
        setopt extendedglob
	input=$(</dev/stdin)
	# by jkramer, source: http://stackoverflow.com/a/187853/928769
        echo "${${(j: :)input}//(#b)(?)/%$[[##16]##${match[1]}]}"
}

