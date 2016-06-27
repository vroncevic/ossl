#!/bin/bash
#
# @brief   Encrypt | decrypt file with openssl
# @version ver.1.0
# @date    Thu Feb 07 00:46:32 2016
# @company Frobas IT Department, www.frobas.com 2016
# @author  Vladimir Roncevic <vladimir.roncevic@frobas.com>
#
UTIL_ROOT=/root/scripts
UTIL_VERSION=ver.1.0
UTIL=$UTIL_ROOT/sh-util-srv/$UTIL_VERSION
UTIL_LOG=$UTIL/log

. $UTIL/bin/checkroot.sh
. $UTIL/bin/checktool.sh
. $UTIL/bin/loadutilconf.sh
. $UTIL/bin/usage.sh
. $UTIL/bin/devel.sh

OSSL_TOOL=ossl
OSSL_VERSION=ver.1.0
OSSL_HOME=$UTIL_ROOT/$OSSL_TOOL/$OSSL_VERSION
OSSL_CFG=$OSSL_HOME/conf/$OSSL_TOOL.cfg
OSSL_UTIL_CFG=$OSSL_HOME/conf/${OSSL_TOOL}_util.cfg
OSSL_LOG=$OSSL_HOME/log

declare -A OSSL_USAGE=(
	[TOOL_NAME]="__$OSSL_TOOL"
	[ARG1]="[OPTION] e | d (encrypt | decrypt) file"
	[EX-PRE]="# Encrypt some file"
	[EX]="__$OSSL_TOOL e /opt/origin.txt"
)

TOOL_DBG="false"

#
# @brief  Encrypt file
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
            local ROOT_CMD="${cfgosslutil[OSSL]} ${cfgosslutil[OSSL_ALG]}"
            local IN_FILE="-salt -in \"$INPUT_FILE\""
            local OUT_FILE="-out \"$INPUT_FILE.aes\""
            eval "$ROOT_CMD $IN_FILE $OUT_FILE -k \"$PASSWORD\""
        else
            MSG="Check file [$INPUT_FILE]"
            if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
            return $NOT_SUCCESS
        fi
        return $SUCCESS
    fi
    MSG="Check parameters [$INPUT_FILE] [PASSWORD]"
    if [ "$TOOL_DBG" == "true" ]; then
		printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
	else
		printf "$SEND" "[$OSSL_TOOL]" "$MSG"
	fi
    return $NOT_SUCCESS
}


#
# @brief  Decrypt file
# @param  Value required name of file
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
			local ROOT_CMD="${cfgosslutil[OSSL]} ${cfgosslutil[OSSL_ALG]}"
			local IN_FILE="-salt -in \"$INPUT_FILE\""
			eval "$ROOT_CMD -d $IN_FILE"
        else
            MSG="Check file [$INPUT_FILE]"
			if [ "$TOOL_DBG" == "true" ]; then
				printf "$DSTA" "$OSSL_TOOL" "$FUNC" "$MSG"
			else
				printf "$SEND" "[$OSSL_TOOL]" "$MSG"
			fi
            return $NOT_SUCCESS
        fi
        return $SUCCESS
    fi
    MSG="Check argument [$INPUT_FILE]"
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
#			0   - success operation 
#			128 - missing argument
#			129 - missing util config file
#			130 - missing tool
#			131 - failed to encrypt
#			132 - missing file
#			133 - failed to decrypt
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __ossl e "/opt/origin.txt"
#
function __ossl() {
	local OPTION=$1
	local FILE=$2
	local FUNC=${FUNCNAME[0]}
	local MSG=""
	if [ -n "$OPTION" ]; then
		declare -A cfgosslutil=()
		__loadutilconf $OSSL_UTIL_CFG cfgosslutil
		local STATUS=$?
		if [ "$STATUS" -eq "$NOT_SUCCESS" ]; then
			exit 129
		fi
		__checktool "${cfgosslutil[OSSL]}"
		STATUS=$?
		if [ "$STATUS" -eq "$NOT_SUCCESS" ]; then
			exit 130
		fi
		if [ $OPTION == "e" ]; then
			local TMP_PASSWD=""
			stty -echo
			printf "%s" "Enter password: "
			read TMP_PASSWD
			stty echo
			__encrypt $FILE $TMP_PASSWD
			STATUS=$?
			if [ "$STATUS" -eq "$NOT_SUCCESS" ]; then
				exit 131
			fi
			exit 0
		elif [ $OPTION == "d" ]; then
			if [ -n "$FILE" ]; then
				__decrypt $FILE
				STATUS=$?
				if [ "$STATUS" -eq "$NOT_SUCCESS" ]; then
					exit 133
				fi
				exit 0
			fi
			exit 132
		fi
	fi
	__usage $OSSL_USAGE
	exit 128
}

#
# @brief   Main entry point
# @params  Values required module name and option with C code
# @exitval Script tool genpm exit with integer value
#			0   - success operation 
# 			127 - run as root user
#			128 - missing argument
#			129 - missing util config file
#			130 - missing tool
#			131 - failed to encrypt
#			132 - missing file
#			133 - failed to decrypt
#
printf "\n%s\n%s\n\n" "$OSSL_TOOL $OSSL_VERSION" "`date`"
__checkroot
STATUS=$?
if [ "$STATUS" -eq "$SUCCESS" ]; then
	__ossl $1 $2
fi

exit 127
