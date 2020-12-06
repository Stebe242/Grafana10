#!/bin/sh -e

# first arg starts with "-". i.e. is some-option
if [ "${1#-}" != "$1" ]; then
	set -- grafana-server "$@"
fi

# adds default flags if the user wants to start the default service
if [ "$1" = 'grafana-server' ]; then
	shift # drop first entry 
	set -- grafana-server --homepath="$GF_PATHS_HOME" --config="$GF_PATHS_CONFIG" --packaging=docker "$@"
fi

exec "$@"
