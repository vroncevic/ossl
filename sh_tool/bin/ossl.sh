#!/bin/bash
#
# @brief   Encrypt | decrypt target file with tool openssl
# @version ver.1.0
# @date    Thu Feb 07 00:46:32 2016
# @company Frobas IT Department, www.frobas.com 2016
# @author  Vladimir Roncevic <vladimir.roncevic@frobas.com>
#
UTIL_ROOT=/root/scripts
UTIL_VERSION=ver.1.0
UTIL=${UTIL_ROOT}/sh_util/${UTIL_VERSION}
UTIL_LOG=${UTIL}/log

.    ${UTIL}/bin/devel.sh
.    ${UTIL}/bin/usage.sh
.    ${UTIL}/bin/check_root.sh
.    ${UTIL}/bin/check_tool.sh
.    ${UTIL}/bin/check_op.sh
.    ${UTIL}/bin/logging.sh
.    ${UTIL}/bin/load_conf.sh
.    ${UTIL}/bin/load_util_conf.sh
.    ${UTIL}/bin/progress_bar.sh

OSSL_TOOL=ossl
OSSL_VERSION=ver.1.0
OSSL_HOME=${UTIL_ROOT}/${OSSL_TOOL}/${OSSL_VERSION}
OSSL_CFG=${OSSL_HOME}/conf/${OSSL_TOOL}.cfg
OSSL_UTIL_CFG=${OSSL_HOME}/conf/${OSSL_TOOL}_util.cfg
OSSL_LOG=${OSSL_HOME}/log

.    ${OSSL_HOME}/bin/encrypt.sh
.    ${OSSL_HOME}/bin/decrypt.sh

declare -A OSSL_USAGE=(
    [Usage_TOOL]="${OSSL_TOOL}"
    [Usage_ARG1]="[OPERATION] enc | dec (encrypt | decrypt)"
    [Usage_ARG2]="[TARGET FILE] File path"
    [Usage_EX_PRE]="# Encrypt target file"
    [Usage_EX]="${OSSL_TOOL} enc /opt/origin.txt"
)

declare -A OSSL_LOGGING=(
    [LOG_TOOL]="${OSSL_TOOL}"
    [LOG_FLAG]="info"
    [LOG_PATH]="${OSSL_LOG}"
    [LOG_MSGE]="None"
)

declare -A PB_STRUCTURE=(
    [BW]=50
    [MP]=100
    [SLEEP]=0.01
)

TOOL_DBG="false"
TOOL_LOG="false"
TOOL_NOTIFY="false"

#
# @brief   Main function
# @params  Values required encrypt | decrypt and file name
# @exitval Function __ossl exit with integer value
#            0   - tool finished with success operation
#            128 - missing argument(s) from cli
#            129 - failed to load tool script configuration from file
#            130 - failed to load tool script utilities configuration from file
#            131 - missing external tool for encrypt/decrypt files
#            132 - falied to encrypt target file
#            133 - failed to decrypt target file
#            134 - missing target file (check that exist in filesystem)
#
# @usage
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# __ossl enc "/opt/origin.txt"
#
function __ossl {
    local OP=$1 FILE=$2
    if [[ -n "${OP}" && -n "${FILE}" ]]; then
        local FUNC=${FUNCNAME[0]} MSG="None"
        local STATUS_CONF STATUS_CONF_UTIL STATUS
        MSG="Loading basic and util configuration!"
        info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
        progress_bar PB_STRUCTURE
        declare -A config_ossl=()
        load_conf "$OSSL_CFG" config_ossl
        STATUS_CONF=$?
        declare -A config_ossl_util=()
        load_util_conf "$OSSL_UTIL_CFG" config_ossl_util
        STATUS_CONF_UTIL=$?
        declare -A STATUS_STRUCTURE=([1]=$STATUS_CONF [2]=$STATUS_CONF_UTIL)
        check_status STATUS_STRUCTURE
        STATUS=$?
        if [ $STATUS -eq $NOT_SUCCESS ]; then
            MSG="Force exit!"
            info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
            exit 129
        fi
        TOOL_DBG=${config_ossl[DEBUGGING]}
        TOOL_LOG=${config_ossl[LOGGING]}
        TOOL_NOTIFY=${config_ossl[EMAILING]}
        local OPERATIONS=${config_ossl_util[OSSL_OPERATIONS]}
        IFS=' ' read -ra OPS <<< "${OPERATIONS}"
        check_op "${OP}" "${OPS[*]}"
        STATUS=$?
        if [ $STATUS -eq $NOT_SUCCESS ]; then
            MSG="Force exit!"
            info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
            exit 130
        fi
        local OSSL=${config_ossl_util[OSSL]}
        check_tool "${OSSL}"
        STATUS=$?
        if [ $STATUS -eq $NOT_SUCCESS ]; then
            MSG="Install tool ${OSSL}"
            info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
            MSG="Force exit!"
            info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
            exit 131
        fi
        MSG="Checking file [${FILE}]?"
        info_debug_message_que "$MSG" "$FUNC" "$OSSL_TOOL"
        if [ -f "${FILE}" ]; then
            MSG="[ok]"
            info_debug_message_ans "$MSG" "$FUNC" "$OSSL_TOOL"
            if [ "${OP}" == "enc" ]; then
                local TPASS="None"
                while read -s -p 'Type password: ' TPASS && [[ -z "${TPASS}" ]]
                do
                    printf "%s" "Please, no blank passwords!"
                done
                __encrypt $FILE $TPASS
                STATUS=$?
                if [ $STATUS -eq $NOT_SUCCESS ]; then
                    MSG="Force exit!"
                    info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
                    exit 133
                fi
            elif [ "${OP}" == "dec" ]; then
                __decrypt $FILE
                STATUS=$?
                if [ $STATUS -eq $NOT_SUCCESS ]; then
                    MSG="Force exit!"
                    info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
                    exit 134
                fi
            fi
            MSG="Operation ${OP}, file: ${FILE} done"
            OSSL_LOGGING[LOG_MSGE]=$MSG
            OSSL_LOGGING[LOG_FLAG]="info"
            logging OSSL_LOGGING
            info_debug_message_end "Done" "$FUNC" "$OSSL_TOOL"
            exit 0
        fi
        MSG="[not ok]"
        info_debug_message_ans "$MSG" "$FUNC" "$OSSL_TOOL"
        MSG="Missing file [${FILE}]"
        info_debug_message "$MSG" "$FUNC" "$OSSL_TOOL"
        MSG="Force exit!"
        info_debug_message_end "$MSG" "$FUNC" "$OSSL_TOOL"
        exit 132
    fi
    usage OSSL_USAGE
    exit 128
}

#
# @brief   Main entry point of script tool
# @params  Values required encrypt\decrypt option and target file
# @exitval Script tool ossl exit with integer value
#            0   - tool finished with success operation
#            127 - run tool script as root user from cli
#            128 - missing argument(s) from cli
#            129 - failed to load tool script configuration from files
#            130 - wrong argument
#            131 - missing external tool for encrypt/decrypt files
#            132 - falied to encrypt target file
#            133 - failed to decrypt target file
#            134 - missing target file (check that exist in filesystem)
#
printf "\n%s\n%s\n\n" "${OSSL_TOOL} ${OSSL_VERSION}" "`date`"
check_root
STATUS=$?
if [ $STATUS -eq $SUCCESS ]; then
    __ossl $1 $2
fi

exit 127

