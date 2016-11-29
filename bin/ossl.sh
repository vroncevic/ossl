#!/bin/bash
#
# @brief   Encrypt | decrypt target file with external tool openssl
# @version ver.1.0
# @date    Thu Feb 07 00:46:32 2016
# @company Frobas IT Department, www.frobas.com 2016
# @author  Vladimir Roncevic <vladimir.roncevic@frobas.com>
#
UTIL_ROOT=/root/scripts
UTIL_VERSION=ver.1.0
UTIL=$UTIL_ROOT/sh-util-srv/$UTIL_VERSION
UTIL_LOG=$UTIL/log

. $UTIL/bin/devel.sh
. $UTIL/bin/usage.sh
. $UTIL/bin/checkroot.sh
. $UTIL/bin/checktool.sh
. $UTIL/bin/logging.sh
. $UTIL/bin/sendmail.sh
. $UTIL/bin/loadconf.sh
. $UTIL/bin/loadutilconf.sh

OSSL_TOOL=ossl
OSSL_VERSION=ver.1.0
OSSL_HOME=$UTIL_ROOT/$OSSL_TOOL/$OSSL_VERSION
OSSL_CFG=$OSSL_HOME/conf/$OSSL_TOOL.cfg
OSSL_UTIL_CFG=$OSSL_HOME/conf/${OSSL_TOOL}_util.cfg
OSSL_LOG=$OSSL_HOME/log

declare -A OSSL_USAGE=(
	[USAGE_TOOL]="$OSSL_TOOL"
	[USAGE_ARG1]="[OPTION] e | d (encrypt | decrypt) file"
	[USAGE_EX_PRE]="# Encrypt target file"
	[USAGE_EX]="$OSSL_TOOL e /opt/origin.txt"
)

declare -A OSSL_LOGGING=(
	[LOG_TOOL]="$OSSL_TOOL"
	[LOG_FLAG]="info"
	[LOG_PATH]="$OSSL_LOG"
	[LOG_MSGE]="None"
)

TOOL_DBG="false"

#
# @brief  Encrypt target file
# @params Values required filename to encrypt and password
# @retval Success return 0, else 1
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __encrypt $FILE $PASSWORD
# local STATUS=$?
#
# if [ $STATUS -eq $SUCCESS ]; then
#   # true
#   # notify admin | user
# else
#   # false
#   # missing argument(s) | missing file
#   # return $NOT_SUCCESS
#   # or
#   # exit 128
# fi
#
function __encrypt() {
    local INPUT_FILE=$1
    local PASSWORD=$2
	local FUNC=${FUNCNAME[0]}
	local MSG=""
    if [ -n "$INPUT_FILE" ] && [ -n "$PASSWORD" ]; then
        if [ -f "$INPUT_FILE" ]; then
            local ROOT_CMD="${configosslutil[OSSL]} ${configosslutil[OSSL_ALG]}"
            local IN_FILE="-salt -in $INPUT_FILE"
            local OUT_FILE="-out $INPUT_FILE.aes"
            eval "$ROOT_CMD $IN_FILE $OUT_FILE -k $PASSWORD"
        else
            MSG="Please check target file [$INPUT_FILE]"
			if [ "${configossl[LOGGING]}" == "true" ]; then
				OSSL_LOGGING[LOG_MSGE]="$MSG"
				OSSL_LOGGING[LOG_FLAG]="error"
				__logging OSSL_LOGGING
			fi
            if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
            return $NOT_SUCCESS
        fi
		if [ "${configossl[LOGGING]}" == "true" ]; then
			MSG="Encrypted file: $IN_FILE > $OUT_FILE"
			OSSL_LOGGING[LOG_FLAG]="info"
			OSSL_LOGGING[LOG_MSGE]="$MSG"
			__logging OSSL_LOGGING
		fi
        return $SUCCESS
    fi
    MSG="Please check parameters [$INPUT_FILE] [PASSWORD]"
	if [ "${configossl[LOGGING]}" == "true" ]; then
		OSSL_LOGGING[LOG_MSGE]="$MSG"
		OSSL_LOGGING[LOG_FLAG]="error"
		__logging OSSL_LOGGING
	fi
    if [ "$TOOL_DBG" == "true" ]; then
		printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
	else
		printf "$SEND" "[$OSSL_TOOL]" "$MSG"
	fi
    return $NOT_SUCCESS
}


#
# @brief  Decrypt target file
# @param  Value required name of target file
# @retval Success return 0, else 1
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __decrypt $FILE
# local STATUS=$?
#
# if [ $STATUS -eq $SUCCESS ]; then
#   # true
#   # notify admin | user
# else
#   # false
#   # missing argument | missing file
#   # return $NOT_SUCCESS
#   # or
#   # exit 128
# fi
#
function __decrypt() {
    local INPUT_FILE=$1
    local FUNC=${FUNCNAME[0]}
	local MSG=""
    if [ -n "$INPUT_FILE" ]; then
        if [ -f "$INPUT_FILE" ]; then
			local ROOT_CMD="${configosslutil[OSSL]} ${configosslutil[OSSL_ALG]}"
			local IN_FILE="-salt -in $INPUT_FILE"
			eval "$ROOT_CMD -d $IN_FILE"
        else
            MSG="Please check target file [$INPUT_FILE]"
			if [ "${configossl[LOGGING]}" == "true" ]; then
				OSSL_LOGGING[LOG_MSGE]="$MSG"
				OSSL_LOGGING[LOG_FLAG]="error"
				__logging OSSL_LOGGING
			fi
			if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
            return $NOT_SUCCESS
        fi
		if [ "${configossl[LOGGING]}" == "true" ]; then
			MSG="Decrypted file: $IN_FILE"
			OSSL_LOGGING[LOG_MSGE]="$MSG"
			OSSL_LOGGING[LOG_FLAG]="info"
			__logging OSSL_LOGGING
		fi
        return $SUCCESS
    fi
    MSG="Please check target file [$INPUT_FILE]"
	if [ "${configossl[LOGGING]}" == "true" ]; then
		OSSL_LOGGING[LOG_MSGE]="$MSG"
		OSSL_LOGGING[LOG_FLAG]="error"
		__logging OSSL_LOGGING
	fi
    if [ "$TOOL_DBG" == "true" ]; then
		printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
	else
		printf "$SEND" "[$OSSL_TOOL]" "$MSG"
	fi
    return $NOT_SUCCESS
}

#
# @brief   Main function 
# @params  Values required encrypt | decrypt and file name
# @exitval Function __ossl exit with integer value
#			0   - tool finished with success operation 
#			128 - missing argument(s) from cli 
#			129 - failed to load tool script configuration from file 
#			130 - failed to load tool script utilities configuration from file
#			131 - missing external tool for encrypt/decrypt files
#			132 - falied to encrypt target file
#			133 - failed to decrypt target file
#			134 - missing target file (check that exist in filesystem)
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __ossl e "/opt/origin.txt"
#
function __ossl() {
	local OPTION=$1
	local FILE=$2
	if [ -n "$OPTION" ] && [ -n "$FILE" ]; then
		local FUNC=${FUNCNAME[0]}
		local MSG=""
		declare -A configossl=()
		__loadconf $OSSL_CFG configossl
		local STATUS=$?
		if [ $STATUS -eq $NOT_SUCCESS ]; then
			MSG="Failed to load tool script configuration"
			if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
			exit 129
		fi
		declare -A configosslutil=()
		__loadutilconf $OSSL_UTIL_CFG configosslutil
		STATUS=$?
		if [ $STATUS -eq $NOT_SUCCESS ]; then
			MSG="Failed to load tool script utilities configuration"
			if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
			exit 130
		fi
		__checktool "${configosslutil[OSSL]}"
		STATUS=$?
		if [ $STATUS -eq $NOT_SUCCESS ]; then
			MSG="Missing external tool ${configosslutil[OSSL]}"
			if [ "${configossl[LOGGING]}" == "true" ]; then
				OSSL_LOGGING[LOG_MSGE]="$MSG"
				OSSL_LOGGING[LOG_FLAG]="error"
				__logging OSSL_LOGGING
			fi
			if [ "${configossl[EMAILING]}" == "true" ]; then
				__sendmail "$MSG" "${configossl[ADMIN_EMAIL]}"
			fi
			exit 131
		fi
		if [ "$OPTION" == "e" ]; then
			local TMP_PASSWD=""
			while read -s -p 'Enter password: ' TMP_PASSWD && [[ -z "$TMP_PASSWD" ]]
			do
				printf "%s" "Please, no blank passwords!"
			done
			__encrypt $FILE $TMP_PASSWD
			STATUS=$?
			if [ $STATUS -eq $NOT_SUCCESS ]; then
				exit 132
			fi
			exit 0
		elif [ "$OPTION" == "d" ]; then
			if [ -f "$FILE" ]; then
				__decrypt $FILE
				STATUS=$?
				if [ $STATUS -eq $NOT_SUCCESS ]; then
					exit 133
				fi
				exit 0
			fi
			MSG="Missing target file $FILE"
			if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
			exit 134
		fi
	fi
	__usage OSSL_USAGE
	exit 128
}

#
# @brief   Main entry point of script tool
# @params  Values required encrypt\decrypt option and target file
# @exitval Script tool ossl exit with integer value
#			0   - tool finished with success operation 
# 			127 - run tool script as root user from cli
#			128 - missing argument(s) from cli 
#			129 - failed to load tool script configuration from file 
#			130 - failed to load tool script utilities configuration from file
#			131 - missing external tool for encrypt/decrypt files
#			132 - falied to encrypt target file
#			133 - failed to decrypt target file
#			134 - missing target file (check that exist in filesystem)
#
printf "\n%s\n%s\n\n" "$OSSL_TOOL $OSSL_VERSION" "`date`"
__checkroot
STATUS=$?
if [ $STATUS -eq $SUCCESS ]; then
	__ossl $1 $2
fi

exit 127

