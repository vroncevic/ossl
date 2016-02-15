#!/bin/bash
#
# @brief   Encrypt and decrypt file with openssl
# @version ver.1.0
# @date    Thu Feb 07 00:46:32 2016
# @company Frobas IT Department, www.frobas.com 2016
# @author  Vladimir Roncevic <vladimir.roncevic@frobas.com>
#
TOOL_NAME="${BASH_SOURCE[0]}"

SUCCESS=0
NOT_SUCCESS=1

#
# @brief Encrypt file
# @params filename to encrypt and password
# @retval Success return 0, else 1
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __encrypt $FILE $PASSWORD
# STATUS=$?
#
# if [ $STATUS -eq $SUCCESS ]; then
#   # true
# else
#   # false
# fi
#
function __encrypt() {
    INPUT_FILE=$1
    PASSWORD=$2
    if [ -n "$INPUT_FILE" ] && [ -n "$PASSWORD" ]; then
        if [ -f "$INPUT_FILE" ]; then
            openssl aes-256-cbc -salt -in "$INPUT_FILE" -out "$INPUT_FILE.aes" -k "$PASSWORD"
        else
            printf "%s\n" " Check file [$INPUT_FILE]"
            return $NOT_SUCCESS
        fi
        return $SUCCESS
        
    fi
    printf "%s\n" "Check parameters!"
    return $NOT_SUCCESS
}


#
# @brief Decrypt file
# @retval Success return 0, else 1
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __decrypt $FILE
# STATUS=$?
#
# if [ $STATUS -eq $SUCCESS ]; then
#   # true
# else
#   # false
# fi
#
function __decrypt() {
    INPUT_FILE=$1
    if [ -n "$INPUT_FILE" ]; then
        if [ -f "$INPUT_FILE" ]; then
            openssl aes-256-cbc -d -salt -in $INPUT_FILE
        else
            printf "%s\n" " Check file [$INPUT_FILE]"
            return $NOT_SUCCESS
        fi
        return $SUCCESS
    fi
    printf "%s\n" "Check file [$INPUT_FILE]"
    return $NOT_SUCCESS
}


#
# @brief Main entry point
# @params required option, file path
#

OPTION=$1
FILE=$2

if [ $# -ne 2 ]; then
    printf "%s\n" " usage: $TOOL_NAME [OPTION] [FILE]"
    printf "%s\n" "[OPTION]  e encrypt | d decrypt"
    printf "%s\n" "[FILE]    path to the file"
    exit 127
fi

if [ $OPTION == "e" ]; then
    TMP_PASSWD=""
    stty -echo
    printf "%s" "Enter password: "
    read TMP_PASSWD
    stty echo
    __encrypt $FILE $TMP_PASSWD
elif [ $OPTION == "d" ]; then
    __decrypt $FILE
fi

exit 0
