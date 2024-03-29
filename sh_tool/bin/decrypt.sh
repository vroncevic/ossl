#!/bin/bash
#
# @brief   Encrypt | decrypt target file with tool openssl
# @version ver.1.0
# @date    Sat 27 Nov 2021 07:58:38 PM CET
# @company None, free software to use 2016
# @author  Vladimir Roncevic <vladimir.roncevic@frobas.com>
#

declare -A OSSL_DECRYPT_USAGE=(
    [USAGE_TOOL]="__decrypt"
    [USAGE_ARG1]="[FILE] Target file"
    [USAGE_EX_PRE]="# Decrypt target file"
    [USAGE_EX]="__decrypt /opt/origin.aes"
)

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
#    # true
#    # notify admin | user
# else
#    # false
#    # missing argument | missing file
#    # return $NOT_SUCCESS
#    # or
#    # exit 128
# fi
#
function __decrypt {
    local INF=$1 FUNC=${FUNCNAME[0]} MSG="None"
    if [ -n "${INF}" ]; then
        MSG="Decrypt file [${INF}]"
        info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
        if [ -f "${INF}" ]; then
            local OSSLT=${config_ossl_util[OSSL]}
            local OSSLA=${config_ossl_util[OSSL_ALG]}
            local IN_FILE="-salt -in ${INF}"
            eval "${OSSLT} ${OSSLA} -d ${IN_FILE}"
            info_debug_message_end "Done" "$FUNC" "$OSSL_TOOL"
            return $SUCCESS
        fi
        MSG="Check file [${INF}]"
        info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
        MSG="Force exit!"
        info_debug_message-end "$MSG" "$FUNC" "$OSSL_TOOL"
        return $NOT_SUCCESS
    fi
    usage OSSL_DECRYPT_USAGE
    return $NOT_SUCCESS
}

