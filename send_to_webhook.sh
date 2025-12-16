#!/bin/bash

export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export INSTALL_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/maubot_vars.env"

function loud() {
    if [ "${LOUD:-0}" -eq 1 ];then
        echo "$@"
    fi
}


if [ $# -eq 0 ]; then
    # no arguments passed, use stdin
    jbody=$(cat)
else
	while [ $# -gt 0 ]; do
		option="$1"
		case $option in
		--loud)
			LOUD=1
			shift
			;;
		--title)
			shift
			jtitle="${1}"
			shift
			;;
		--body)
			shift
			jbody="$*"
			break
			;;
		*) shift ;;
		esac
	done
	if [ -z "${jtitle}" ];then
		jtitle="Notification!"
	fi
	if [ -z "${jbody}" ];then
		jbody=$(cat)
		if [ -z "${jbody}" ];then
			jbody=" "
		fi
	fi
	loud "[info] Posting reply to maubot"
#   Build the JSON safely with jq
	json_payload=$(jq -n --arg title "${jtitle}" --arg body "${jbody}" '{ title: $title,body: $body}')

	# Then send it with curl
	curl -X POST -H "Content-Type: application/json" "${MATRIXSERVER}/_matrix/maubot/plugin/${MAUBOT_STATUS_WEBHOOK_INSTANCE}/send" -d "$json_payload"
	loud "[info] Posted to maubot"  

fi
