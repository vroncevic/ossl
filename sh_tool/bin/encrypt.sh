#!/bin/bash
#
# @brief   Encrypt | decrypt target file with tool openssl
# @version ver.1.0
# @date    Sat 27 Nov 2021 07:58:38 PM CET
# @company None, free software to use 2016
# @author  Vladimir Roncevic <vladimir.roncevic@frobas.com>
#

declare -A OSSL_ENCRYPT_USAGE=(
    [USAGE_TOOL]="__encrypt"
    [USAGE_ARG1]="[FILE] Target file"
    [USAGE_ARG2]="[PASSWORD] Password"
    [USAGE_EX_PRE]="# Encrypt target file"
    [USAGE_EX]="__encrypt /opt/origin.txt \$PASS"
)

#
# @brief  Encrypt target file
# @params Values required filename to encrypt and password
# @retval Success return 0, else 1
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __encrypt $FILE $PASS
# local STATUS=$?
#
# if [ $STATUS -eq $SUCCESS ]; then
#    # true
#    # notify admin | user
# else
#    # false
#    # missing argument(s) | missing file
#    # return $NOT_SUCCESS
#    # or
#    # exit 128
# fi
#
function __encrypt {
    local INF=$1 PASS=$2 FUNC=${FUNCNAME[0]} MSG="None"
    if [[ -n "${INF}" && -n "${PASS}" ]]; then
        MSG="Encrypt file [${INF}]"
        info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
        if [ -f "${INF}" ]; then
            local OSSLT=${config_ossl_util[OSSL]}
            local OSSLA=${config_ossl_util[OSSL_ALG]}
            local IN_FILE="-salt -in ${INF}" OUT_FILE="-out ${INF}.aes"
            eval "${OSSLT} ${OSSLA} ${IN_FILE} ${OUT_FILE} -k ${PASS}"
            MSG="Encrypted file: ${IN_FILE} > ${OUT_FILE}"
            info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
            info_debug_message_end "Done" "$FUNC" "$OSSL_TOOL"
            return $SUCCESS
        fi
        MSG="Check file [${INF}]"
        info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
        MSG="Force exit!"
        info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
        return $NOT_SUCCESS
    fi
    usage OSSL_ENCRYPT_USAGE
    return $NOT_SUCCESS
}

