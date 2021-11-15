#!/bin/zsh
#dep:curl
# installs or updates to latest release of Proton build by GloriousEggroll
# saves installed versions in $STEAM_DIR/compatibilitytools.d/proton-ge-tags

autoload -Uz colors && colors

if [[ ! -e $HOME/.steam/root/ ]]; then
	if [[ -e $HOME/.var/app/com.valvesoftware.Steam/data/Steam ]]; then
		#flatpak-version
		COMPTOOLSDIR=$HOME/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/
	fi
	echo "steam root not found"
	exit 1
else
	COMPTOOLSDIR=$HOME/.steam/root/compatibilitytools.d
fi

mkdir -p $COMPTOOLSDIR

latest_json=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest)
release_tag=$(jq -r .tag_name <<<$latest_json)
download_url=$(jq -r '.assets|map(select(.name | contains("tar")))|.[0].browser_download_url'<<<"$latest_json")

installed_tags="$COMPTOOLSDIR/proton-ge-tags"

if grep -q "^$release_tag\$" "$installed_tags"; then
	echo "${fg_bold[yellow]}Current release $release_tag already installed.$reset_color"
else
	echo "Downloading $download_url"
	curl -L $download_url | tar -xvz -C $COMPTOOLSDIR \
		&& echo $release_tag >> $installed_tags \
		&& echo "${fg_bold[green]}Installed release $release_tag.$reset_color"
fi
