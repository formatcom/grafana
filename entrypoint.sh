#!/bin/sh

if [ ! -d "$GF_PATHS_PLUGINS" ]; then
	mkdir "$GF_PATHS_PLUGINS"
fi

# Convert all environment variables with names ending in __FILE into the content of
# the file that they point at and use the name without the trailing __FILE.
# This can be used to carry in Docker secrets.
for VAR_NAME in $(env | grep '^GF_[^=]\+__FILE=.\+' | sed -r "s/([^=]*)__FILE=.*/\1/g"); do
	VAR_NAME_FILE="$VAR_NAME"__FILE
	if [ "${!VAR_NAME}" ]; then
		echo >&2 "ERROR: Both $VAR_NAME and $VAR_NAME_FILE are set (but are exclusive)"
		exit 1
	fi
	echo "Getting secret $VAR_NAME from ${!VAR_NAME_FILE}"
	export "$VAR_NAME"="$(< "${!VAR_NAME_FILE}")"
	unset "$VAR_NAME_FILE"
done

export HOME="$GF_PATHS_HOME"

if [ ! -z "${GF_INSTALL_PLUGINS}" ]; then
	OLDIFS=$IFS
	IFS=','
	for plugin in ${GF_INSTALL_PLUGINS}; do
		IFS=$OLDIFS
		grafana-cli --pluginsDir "${GF_PATHS_PLUGINS}" plugins install ${plugin}
	done
fi

exec grafana-server                                         \
	--homepath="$GF_PATHS_HOME"                               \
	--config="$GF_PATHS_CONFIG"                               \
	"$@"                                                      \
	cfg:default.log.mode="console"                            \
	cfg:default.paths.data="$GF_PATHS_DATA"                   \
	cfg:default.paths.logs="$GF_PATHS_LOGS"                   \
	cfg:default.paths.plugins="$GF_PATHS_PLUGINS"             \
	cfg:default.paths.provisioning="$GF_PATHS_PROVISIONING"
