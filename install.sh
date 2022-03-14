#!/bin/bash

LBIN=$HOME/.local/bin
L=0

ez_git () {
    echo "Installing ez-git..."
    echo "pull: List your repos to pull, separated by spaces and confirm with enter"
    read REPOS
    echo ""
    echo "----------------"
    echo ""
    echo "pull: Now, tell me your GitHub username"
    read GITUSER
    USER=git\@github\.com\:${GITUSER}\/
    echo ""
    echo "----------------"
    echo ""
    echo "push/pull: which relative path to store your repos?"
    read GITROOT
    echo ""
    echo "----------------"
    echo ""
    if [[ ! -d $LBIN ]]; then
        mkdir -p $LBIN
    fi
    cp ./ez-git/pull $LBIN
    cd $LBIN
    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i "" "/REPOS/c\REPOS=\'${REPOS}\'" pull
        sed -i "" "/USER=/c\USER=${USER}" pull
        sed -i "" "GITROOT=/c\GITROOT=${GITROOT}" pull
    else 
        sed -i "/REPOS=/c\REPOS=\'${REPOS}\'" pull
        sed -i "/USER=/c\USER=${USER}" pull
        sed -i "/GITROOT=/c\GITROOT=${GITROOT}" pull
    fi
    cd - >> /dev/null >> /dev/null
    cp ./ez-git/push $LBIN
    cd $LBIN
    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i "" "/GITROOT=/c\GITROOT=${GITROOT}" pull
    else 
        sed -i "/GITROOT=/c\GITROOT=${GITROOT}" pull
    fi
    cd - >> /dev/null
    echo "DONE! - rerun(1) or exit(2)? (default 1)"
    read A
    if [[ "${A}" = "2" ]]; then
        exit 0
    fi
}

ez_ssh () {
    FILE=./ez-ssh/simple
    echo "Setup simple(1) or bridged(2) ssh script? (default 1)"
    read MODE
    echo ""
    echo "----------------"
    echo ""
    if [[ "${MODE}" = "2" ]]; then
        echo "Provide a hostname or IP address to use as bridge host"
        read BRIDGEHST
        echo ""
        echo "----------------"
        echo ""
        echo "Which local port should be used to create a tunnel to the destinations SSH port? (e.g. 9999)"
        read BRIDGEPORT
        echo ""
        echo "----------------"
        echo ""
        FILE=./ez-ssh/bridged
    fi
    echo "Provide a hostname or IP address for the remote host"
    read HOST
    echo ""
    echo "----------------"
    echo ""
    echo "Now, provide the remote VNC port. (default 5901)"
    read VNCPORT
    echo ""
    echo "----------------"
    echo ""
    echo "And the local tunnel vnc port. (default 5901)"
    read TUNPORT
    echo ""
    echo "----------------"
    echo ""
    echo "Which is the default username to use?"
    read DEFUSER
    echo ""
    echo "----------------"
    echo ""
    echo "Finally, provide a name for this command. Most likely the name of your remote host. (default 'ez-ssh')"
    read CMD
    if [[ ! -d $LBIN ]]; then
        mkdir -p $LBIN
    fi
    if [[ -z "$CMD" ]]; then
        $CMD=ez-ssh
    fi
    cp $FILE $LBIN/$CMD
    cd $LBIN

    if [[ "$(uname)" = "Darwin" ]]; then
        sed -i "" "/HOST=/c\HOST=\'${HOST}\'" $CMD
        if [[ ! -z "${BRIDGEHST}" ]]; then
            sed -i "" "/BRIDGEHST=/c\BRIDGEHST=\'${BRIDGEHST}\'" $CMD
        fi
        if [[ ! -z "${VNCPORT}" ]]; then
            sed -i "" "/VNCPORT=5901/c\VNCPORT=${VNCPORT}" $CMD
        fi
        if [[ ! -z "${TUNPORT}" ]];then 
            sed -i "" "/TUNPORT=5901/c\TUNPORT=${TUNPORT}" $CMD
        fi
        sed -i "" "/DEFUSER=/c\DEFUSER=\'${DEFUSER}\'" $CMD
        if [[ ! -z "${BRIDGEPORT}" ]]; then
            sed -i "" "/BRIDGEPORT=/c\BRIDGEPORT=${BRIDGEPORT}" $CMD
        fi
        sed -i "" "/CMD=/c\CMD=\'${CMD}\'" $CMD
    else
        sed -i "/HOST=/c\HOST=\'${HOST}\'" $CMD
        if [[ ! -z "${BRIDGEHST}" ]]; then
            sed -i "/BRIDGEHST=/c\BRIDGEHST=\'${BRIDGEHST}\'" $CMD
        fi
        if [[ ! -z "${VNCPORT}" ]]; then
            sed -i "/VNCPORT=5901/c\VNCPORT=${VNCPORT}" $CMD
        fi
        if [[ ! -z "${TUNPORT}" ]];then 
            sed -i "/TUNPORT=5901/c\TUNPORT=${TUNPORT}" $CMD
        fi
        sed -i "/DEFUSER=/c\DEFUSER=\'${DEFUSER}\'" $CMD
        if [[ ! -z "${BRIDGEPORT}" ]]; then
            sed -i "/BRIDGEPORT=/c\BRIDGEPORT=${BRIDGEPORT}" $CMD
        fi
        sed -i "/CMD=/c\CMD=\'${CMD}\'" $CMD
    fi
    echo "DONE! - rerun(1) or exit(2)? (default 1)"
    read A
    if [[ "${A}" = "2" ]]; then
        exit 0
    fi
}

while [[ $L = 0 ]]; do
    echo ""
    echo "############################################"
    echo "############################################"
    echo ""
    echo "Installing ez-git(1) or ez-ssh(2)? (default 1)"
    read EZ
    if [[ "${EZ}" = "2" ]]; then  
        ez_ssh
    else
        ez_git
    fi
done