autoload -Uz colors && colors

local c_fail="${fg_bold[red]}✘$reset_color"
local c_warn="${fg_bold[yellow]}⚠$reset_color"
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
warn() { result $c_warn $@ }
succeed() { result $c_success $@ }
error() { echo -n "  "; fail $@ }
warning() { echo -n "  "; warn $@ }

exists() {
	type "$1" &>/dev/null
}

alternative() {
	if ! exists $1; then eval "$1(){ $2 \$@}"; fi
}

alternative-noparam() {
	if ! exists $1; then eval "$1(){ $2 }"; fi
}

depend() {
	local missing
	local i

	for i in "$@"; do
		exists "$i" || {
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

pip-venv-deps() {
	if [[ -n $VIRTUAL_ENV ]]; then
		pip install -qqq "$@"
	else
		echo "Not in a virtual env."
		exit 1
	fi
}
