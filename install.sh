#!/bin/bash

# This script is intended to be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/datflowts/fcknlazyflow/master/install.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/datflowts/fcknlazyflow/master/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/datflowts/fcknlazyflow/master/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/datflowts/fcknlazyflow/master/install.sh
#   ./install.sh
#



# Default settings
FLF="${FLF:-${HOME}/.fcknlazy${USER}}"
REPO=datflowts/fcknlazyflow
REMOTE=https://github.com/${REPO}.git
BRANCH=master
LBIN="${HOME}/.local/bin"
echo 'export PATH=${PATH}:${HOME}/.local/bin' >> .*shrc
L=0

# Manual clone with git config options to support git < v1.7.2
echo "Cloning into ${FLF}..."
git init --quiet "${FLF}" && cd "${FLF}" \
    && git config core.eol lf \
    && git config core.autocrlf false \
    && git config fsck.zeroPaddedFilemode ignore \
    && git config fetch.fsck.zeroPaddedFilemode ignore \
    && git config receive.fsck.zeroPaddedFilemode ignore \
    && git config fcknlazyflow.remote origin \
    && git config fcknlazyflow.branch "${BRANCH}" \
    && git remote add origin "${REMOTE}" \
    && git fetch --depth=1 origin \
    && git checkout -b "${BRANCH}" "origin/${BRANCH}" >/dev/null 2>&1 || {
        [ ! -d "${FLF}" ] || rm -rf "${FLF}" 2>/dev/null
        echo "Error: git clone of fcknlazyflow repo failed!"
        exit 1
    }

ez_git () {
    echo "Installing ez-git..."
    echo "pull: List your repos to pull, separated by spaces and confirm with enter"
    read -p '=> ' -r
    REPOS=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "pull: Now, tell me your GitHub username"
    read -p '=> ' -r 
    USER=git\@github\.com\:${REPLY}\/
    echo ''
    echo "----------------"
    echo ''
    echo "push/pull: which relative path to store your repos?"
    read -p '=> ' -r 
    GITROOT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    cp ${FLF}/ez-git/pull ${LBIN}
    cd ${LBIN}
    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i '' -e "/REPOS/c\\REPOS=\'$REPOS\'" pull
        sed -i '' -e "/USER=/c\\USER=$USER" pull
        sed -i '' -e "/GITROOT=/c\\GITROOT=$GITROOT" pull
    else 
        sed -i "/REPOS=/c\REPOS=\'${REPOS}\'" pull
        sed -i "/USER=/c\USER=${USER}" pull
        sed -i "/GITROOT=/c\GITROOT=${GITROOT}" pull
    fi
    cd - >/dev/null 2>&1
    cp ${FLF}/ez-git/push ${LBIN}
    cd ${LBIN}
    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i '' -e "/GITROOT=/c\\GITROOT=$GITROOT" pull
    else 
        sed -i "/GITROOT=/c\GITROOT=${GITROOT}" pull
    fi
    cd - >/dev/null 2>&1
    echo ''
    read -p 'DONE! - rerun(1) or exit(2)? (default 1) => ' -n 1 -r 
    echo ''
    if [[ "${REPLY}" = "2" ]]; then
        echo "Exiting.."
        cd - >/dev/null 2>&1
        rm -rf "${FLF}" >/dev/null 2>&1
        exit 0
    fi
}

ez_ssh () {
    FILE=${FLF}/ez-ssh/simple
    echo ''
    read -p 'Setup simple(1) or bridged(2) ssh script? (default 1) => ' -n 1 -r 
    echo ''
    echo "----------------"
    echo ''
    if [[ "${REPLY}" = "2" ]]; then
        echo "Provide a hostname or IP address to use as bridge host"
        read -p '=> ' -r 
        BRIDGEHST=${REPLY}
        echo ''
        echo "----------------"
        echo ''
        echo "Which local port should be used to create a tunnel to the destinations SSH port? (e.g. 9999)"
        read -p '=> ' -r 
        BRIDGEPORT=${REPLY}
        echo ''
        echo "----------------"
        echo ''
        FILE=${FLF}/ez-ssh/bridged
    fi
    echo "Provide a hostname or IP address for the remote host"
    read -p '=> ' -r 
    HOST=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Now, provide the remote VNC port. (default 5901)"
    read -p '=> ' -r 
    VNCPORT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "And the local tunnel vnc port. (default 5901)"
    read -p '=> ' -r 
    TUNPORT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Which is the default username to use?"
    read -p '=> ' -r 
    DEFUSER=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Finally, provide a name for this command. Most likely the name of your remote host. (default 'ez-ssh')"
    read -p '=> ' -r 
    echo ''
    CMD=${REPLY}
    if [[ -z "${CMD}" ]]; then
        CMD=ez-ssh
    fi
    cp $FILE ${LBIN}/${CMD}
    cd ${LBIN}

    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i '' -e "/HOST=/c\\HOST=\'${HOST}\'" ${CMD}
        if [[ ! -z "${BRIDGEHST}" ]]; then
            sed -i '' -e "/BRIDGEHST=/c\\BRIDGEHST=\'${BRIDGEHST}\'" ${CMD}
        fi
        if [[ ! -z "${VNCPORT}" ]]; then
            sed -i '' -e "/VNCPORT=5901/c\\VNCPORT=${VNCPORT}" ${CMD}
        fi
        if [[ ! -z "${TUNPORT}" ]];then 
            sed -i '' -e "/TUNPORT=5901/c\\TUNPORT=${TUNPORT}" ${CMD}
        fi
        sed -i '' -e "/DEFUSER=/c\\DEFUSER=\'${DEFUSER}\'" ${CMD}
        if [[ ! -z "${BRIDGEPORT}" ]]; then
            sed -i '' -e "/BRIDGEPORT=/c\\BRIDGEPORT=${BRIDGEPORT}" ${CMD}
        fi
        sed -i '' -e "/CMD=/c\\CMD=\'${CMD}\'" ${CMD}
    else
        sed -i "/HOST=/c\HOST=\'${HOST}\'" ${CMD}
        if [[ ! -z "${BRIDGEHST}" ]]; then
            sed -i "/BRIDGEHST=/c\BRIDGEHST=\'${BRIDGEHST}\'" ${CMD}
        fi
        if [[ ! -z "${VNCPORT}" ]]; then
            sed -i "/VNCPORT=5901/c\VNCPORT=${VNCPORT}" ${CMD}
        fi
        if [[ ! -z "${TUNPORT}" ]];then 
            sed -i "/TUNPORT=5901/c\TUNPORT=${TUNPORT}" ${CMD}
        fi
        sed -i "/DEFUSER=/c\\DEFUSER=\'${DEFUSER}\'" ${CMD}
        if [[ ! -z "${BRIDGEPORT}" ]]; then
            sed -i "/BRIDGEPORT=/c\BRIDGEPORT=${BRIDGEPORT}" ${CMD}
        fi
        sed -i "/CMD=/c\CMD=\'${CMD}\'" ${CMD}
    fi
    echo "Command ${CMD} successfully created!"
    echo ''
    read -p 'DONE! - rerun(1) or exit(2)? (default 1) => ' -n 1 -r 
    echo ''
    if [[ "${REPLY}" = "2" ]]; then
        echo "Exiting.."
        cd - >/dev/null 2>&1
        rm -rf "${FLF}" >/dev/null 2>&1
        exit 0
    fi
}

while [[ $L = 0 ]]; do
    echo ''
    echo "############################################"
    echo "############################################"
    echo ''
    read -p 'Installing ez-git(1), ez-ssh(2) or exit(3)? (default 3) => ' -n 1 -r
    echo ''
    if [[ ! -d ${LBIN} ]]; then
    mkdir -p ${LBIN}
    fi
    case $REPLY in
        1)
            ez_git
            ;;
        2)
            ez_ssh
            ;;
        *)
            echo "Exiting.."
            cd - >/dev/null 2>&1
            rm -rf "${FLF}" >/dev/null 2>&1
            exit 0
            ;;
    esac
done
