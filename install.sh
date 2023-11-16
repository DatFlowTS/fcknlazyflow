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
PATH_EXPORT="export PATH='\$PATH:'${LBIN}'"
PATH_TESTFILE=$HOME/test_path
echo "${PATH}" >> "${PATH_TESTFILE}"
if ! grep -q "${LBIN}" "${PATH_TESTFILE}" ; then
    echo "${PATH_EXPORT}" >> .zshrc
    echo "${PATH_EXPORT}" >> .bashrc
    export PATH=${PATH}:${HOME}/.local/bin
fi
rm -f "${PATH_TESTFILE}"

# Test, if directory exists
if [[ -d "$FLF" ]]
then
    rm -rf $FLF
fi
# Manual clone with git config options to support git < v1.7.2
echo "Cloning into ${FLF}..."
git init --quiet "${FLF}" && cd "${FLF}" || return
git config core.eol lf
git config core.autocrlf false
git config fsck.zeroPaddedFilemode ignore
git config fetch.fsck.zeroPaddedFilemode ignore
git config receive.fsck.zeroPaddedFilemode ignore
git config fcknlazyflow.remote origin
git config fcknlazyflow.branch "${BRANCH}"
git remote add origin "${REMOTE}"
git fetch --depth=1 origin
git checkout -b "${BRANCH}" "origin/${BRANCH}" >/dev/null 2>&1 || {
    [ ! -d "${FLF}" ] || rm -rf "${FLF}" 2>/dev/null
    echo "Error: git clone of fcknlazyflow repo failed\!"
    exit 1
}


ez_done () {
    echo "DONE\!"
    echo '(1) - return to main menu'
    echo '(2) - exit'
    read -p 'default (1) => ' -n 1 -r
    echo ''
    case $REPLY in
        2)
            ez_exit
        ;;
        *)
            main_menu
        ;;
    esac
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
    cp ${FLF}/ez-git/push ${LBIN}
    if [[ "$OS" = "darwin" ]]; then
        gsed -i "/^REPOS=.*/c\REPOS=\'${REPOS}\'" ${LBIN}/pull
        gsed -i "/^USER=.*/c\USER=${USER}" ${LBIN}/pull
        gsed -i "/^GITROOT=.*/c\GITROOT=${GITROOT}" ${LBIN}/pull
        gsed -i "/^GITROOT=.*/c\GITROOT=${GITROOT}" ${LBIN}/push
    else
        sed -i "/^REPOS=.*/c\REPOS=\'${REPOS}\'" ${LBIN}/pull
        sed -i "/^USER=.*/c\USER=${USER}" ${LBIN}/pull
        sed -i "/^GITROOT=.*/c\GITROOT=${GITROOT}" ${LBIN}/pull
        sed -i "/^GITROOT=.*/c\GITROOT=${GITROOT}" ${LBIN}/push
    fi
    echo ''
    ez_done
}

ez_ssh () {
    FILE=${FLF}/ez-ssh/simple
    echo ''
    echo 'Choose:'
    echo '(1) - simple direct ssh script to remote host'
    echo '(2) - for connections to hosts via another host as bridge'
    echo '(3) - return to main menu'
    echo '(4) - exit'
    read -p 'default (1) => ' -n 1 -r
    echo ''
    echo "----------------"
    echo ''
    if [[ "${REPLY}" = "2" ]]; then
        echo "Provide a hostname or IP address to use as jump host"
        read -p '=> ' -r
        JUMP_HOST=${REPLY}
        echo ''
        echo "----------------"
        echo ''
        echo "Which port on our jump host listens for ssh connections? (default 22)"
        read -p '=> ' -r
        SSH_JUMP_PORT=${REPLY}
        echo ''
        echo "----------------"
        echo ''
        echo "Which is the jump host's username?"
        read -p '=> ' -r
        JUMP_USER=${REPLY}
        echo ''
        echo "----------------"
        FILE=${FLF}/ez-ssh/bridged
        elif [[ "${REPLY}" = "3" ]]; then
        main_menu
        exit 0
        elif [[ "${REPLY}" = "4" ]]; then
        ez_exit
    fi
    echo "Which local port should be tunneled to the remotes SSH port? (default 10022)"
    read -p '=> ' -r
    SSH_LOCAL_PORT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Which is the remote username? (not vnc!)"
    read -p '=> ' -r
    REMOTE_USER=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Which is the vnc user's username?"
    read -p '=> ' -r
    VNC_USER=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Provide a hostname or IP address for the remote host"
    read -p '=> ' -r
    REMOTE_HOST=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Now, provide the remote VNC port. (default 5901)"
    read -p '=> ' -r
    VNC_REMOTE_PORT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "And the local tunnel vnc port. (default 5901)"
    read -p '=> ' -r
    VNC_LOCAL_PORT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Which port listens for ssh connections on the remote host? (default 22)"
    read -p '=> ' -r
    SSH_REMOTE_PORT=${REPLY}
    echo ''
    echo "----------------"
    echo ''
    echo "Finally, provide a name for this command. Most likely the name of your remote host. (default '$REMOTE_HOST')"
    read -p '=> ' -r
    echo ''
    CMD=${REPLY}
    if [[ -z "${CMD}" ]]; then
        CMD="${REMOTE_HOST}"
    fi
    cp "${FILE}" "${LBIN}/${CMD}"
    if [[ "$OS" = "darwin" ]]; then
        gsed -i "/^REMOTE_HOST=.*/c\REMOTE_HOST=\'${REMOTE_HOST}\'" "${LBIN}/${CMD}"
        gsed -i "/^REMOTE_USER=.*/c\REMOTE_USER=\'${REMOTE_USER}\'" "${LBIN}/${CMD}"
        #
        # only changing, if a value is given - otherwise it'll keep default
        if [[ ! -z "${JUMP_HOST}" ]]; then
            gsed -i "/^JUMP_HOST=.*/c\JUMP_HOST=\'${JUMP_HOST}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${JUMP_USER}" ]]; then
            gsed -i "/^JUMP_USER=.*/c\JUMP_USER=\'${JUMP_USER}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${VNC_USER}" ]]; then
            gsed -i "/^VNC_USER=.*/c\VNC_USER=\'${VNC_USER}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${VNC_REMOTE_PORT}" ]]; then
            gsed -i "/^VNC_REMOTE_PORT=.*/c\VNC_REMOTE_PORT=\'${VNC_REMOTE_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${VNC_LOCAL_PORT}" ]];then
            gsed -i "/^VNC_LOCAL_PORT=.*/c\VNC_LOCAL_PORT=\'${VNC_LOCAL_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${SSH_LOCAL_PORT}" ]]; then
            gsed -i "/^SSH_LOCAL_PORT=.*/c\SSH_LOCAL_PORT=\'${SSH_LOCAL_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${SSH_JUMP_PORT}" ]]; then
            gsed -i "/^SSH_JUMP_PORT=.*/c\SSH_JUMP_PORT=\'${SSH_JUMP_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${SSH_REMOTE_PORT}" ]]; then
            gsed -i "/^SSH_REMOTE_PORT=.*/c\SSH_REMOTE_PORT=\'${SSH_REMOTE_PORT}\'" "${LBIN}/${CMD}"
        fi
    else
        sed -i "/^REMOTE_HOST=.*/c\REMOTE_HOST=\'${REMOTE_HOST}\'" "${LBIN}/${CMD}"
        sed -i "/^REMOTE_USER=.*/c\REMOTE_USER=\'${REMOTE_USER}\'" "${LBIN}/${CMD}"
        #
        # only changing, if a value is given - otherwise it'll keep default
        if [[ ! -z "${JUMP_HOST}" ]]; then
            sed -i "/^JUMP_HOST=.*/c\JUMP_HOST=\'${JUMP_HOST}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${JUMP_USER}" ]]; then
            sed -i "/^JUMP_USER=.*/c\JUMP_USER=\'${JUMP_USER}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${VNC_USER}" ]]; then
            sed -i "/^VNC_USER=.*/c\VNC_USER=\'${VNC_USER}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${VNC_REMOTE_PORT}" ]]; then
            sed -i "/^VNC_REMOTE_PORT=.*/c\VNC_REMOTE_PORT=\'${VNC_REMOTE_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${VNC_LOCAL_PORT}" ]];then
            sed -i "/^VNC_LOCAL_PORT=.*/c\VNC_LOCAL_PORT=\'${VNC_LOCAL_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${SSH_LOCAL_PORT}" ]]; then
            sed -i "/^SSH_LOCAL_PORT=.*/c\SSH_LOCAL_PORT=\'${SSH_LOCAL_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${SSH_JUMP_PORT}" ]]; then
            sed -i "/^SSH_JUMP_PORT=.*/c\SSH_JUMP_PORT=\'${SSH_JUMP_PORT}\'" "${LBIN}/${CMD}"
        fi
        if [[ ! -z "${SSH_REMOTE_PORT}" ]]; then
            sed -i "/^SSH_REMOTE_PORT=.*/c\SSH_REMOTE_PORT=\'${SSH_REMOTE_PORT}\'" "${LBIN}/${CMD}"
        fi
    fi
    EXPORT_VAR="export $(echo "$CMD" | tr '[:lower:]' '[:upper:]')=${REMOTE_HOST}"
    if ! grep -q "$EXPORT_VAR" "$HOME/.zshrc" ; then
        echo "$EXPORT_VAR" >> .zshrc
        export "$(echo "$CMD" | tr '[:lower:]' '[:upper:]')"="${REMOTE_HOST}"
    fi
    echo "Command ${CMD} successfully created\!"
    echo ''
    ez_done
}

ez_update () {
    cp -fv "${FLF}/ez-misc/update" "${LBIN}"
    chmod 555 "${LBIN}/update"
    read -p "Update now? Y/N (default N) => " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        update
    else
        echo "Just type 'update' to run it later."
    fi
    ez_done
}

ez_neofetch () {
    which neofetch >/dev/null
    if [[ $? != 0 ]]; then
        NFP=/usr/local/bin/neofetch
    else
        NFP=$(which neofetch)
    fi
    curl -s https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch | sudo tee $NFP
    sudo chmod -v 555 "$NFP"
    ez_done
}

get_distro () {
    OS=""
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$ID
        elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si | grep -Eo '^[^ ]+' | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$(echo "$DISTRIB_ID" | grep -Eo '^[^ ]+' | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=debian
        elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        OS=$(cat /etc/redhat-release | grep -Eo '^[^ ]+' | tr '[:upper:]' '[:lower:]')
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s | grep -Eo '^[^ ]+' | tr '[:upper:]' '[:lower:]')
    fi
    export OS
}

ez_speedtest () {
    case $OS in
        darwin)
            brew tap teamookla/speedtest
            brew update
            brew install speedtest --force
        ;;
        ubuntu|debian)
            if [[ ! $(which curl) ]]; then
                sudo apt-get install curl
            fi
            curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
            sudo apt-get update
            sudo apt-get install speedtest
        ;;
        fedora|centos|redhat)
            if [[ ! $(which curl) ]]; then
                sudo yum -y install curl
            fi
            curl -s https://install.speedtest.net/app/cli/install.rpm.sh | sudo bash
            sudo yum install speedtest
        ;;
        *)
            mkdir "$HOME/inst";cd "$HOME/inst" || return
            wget https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-x86_64.tgz
            tar -xvf ookla-speedtest-1.1.1-linux-x86_64.tgz
            chmod 555 speedtest;sudo cp speedtest /usr/local/bin/
            cd - || return > /dev/null
            rm -rf "$HOME/inst"
        ;;
    esac
    read -p "Run speedtest? Y/N (default N)" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        speedtest
    else
        echo "Just type 'speedtest' to run it later."
    fi
    ez_done
}

ez_zsh () {
    cd ${FLF}/ez-misc
    chmod +x zsh
    ./zsh
    cd - >/dev/null
    ez_done
}

rocky_mirror () {
    get_distro
    case $OS in
        rocky)
            cd ${FLF}/ez-misc
            chmod +x rocky-mirror
            ./rocky-mirror
            cd - >/dev/null
            ez_done
        ;;
        *)
            echo "This mirror only works for RockyLinux."
            echo "Returning to main menu..."
            main_menu
        ;;
    esac
}

ez_misc () {
    echo ''
    echo "############################################"
    echo "############################################"
    echo ''
    echo 'Choose install:'
    echo '(1) - update script'
    echo '(2) - neofetch from master'
    echo '(3) - speedtest-cli'
    echo '(4) - latest zsh with a fancy theme'
    echo '(5) - custom mirror for RockyLinux'
    echo '(6) - return to main menu'
    echo '(7) - exit'
    read -p 'default: (6) => ' -n 1 -r
    echo ''
    if [[ ! -d ${LBIN} ]]; then
        mkdir -p ${LBIN}
    fi
    case $REPLY in
        1)
            ez_update
        ;;
        2)
            ez_neofetch
        ;;
        3)
            ez_speedtest
        ;;
        4)
            ez_zsh
        ;;
        5)
            rocky_mirror
        ;;
        6)
            main_menu
        ;;
        *)
            ez_exit
        ;;
    esac
}

ez_exit () {
    echo "Exiting.."
    cd - >/dev/null 2>&1
    rm -rf "${FLF}" >/dev/null 2>&1
    export L=1
    exit 0
}

main_menu () {
    echo ''
    echo "############################################"
    echo "############################################"
    echo ''
    echo '-- Main Menu --'
    echo 'Choose from the following options:'
    echo '(1) - useful scripts to push/pull/clone your GitHub repos'
    echo '(2) - simplified ssh scripts per host'
    echo '(3) - other stuff'
    echo '(4) - exit'
    read -p 'default: (4) => ' -n 1 -r
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
        3)
            ez_misc
        ;;
        *)
            ez_exit
        ;;
    esac
}

export L=0
get_distro
while [[ $L = 0 ]]; do
    if [[ "$OS" = "darwin" ]]; then
        echo "Checking dependencies first..."
        which brew
        if [[ $? != 0 ]]; then
            echo "Homebrew is missing, but required\!"
            read -p "Install now? (Y/N, default N) => " -n 1 -r
            echo ''
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                xcode-select --install
                bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zshrc" &&
                ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zprofile" ; then
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zshrc
                elif ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zshrc" &&
                grep -q 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zprofile" ; then
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zshrc
                elif grep -q 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zshrc" &&
                ! grep -q 'eval "$(/usr/local/bin/brew shellenv)"' "$HOME/.zprofile" ; then
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
                fi
                eval "$(/usr/local/bin/brew shellenv)"
            else
                ez_exit
            fi
        fi
        brew update >/dev/null 2>&1
        brew upgrade >/dev/null 2>&1
        if ! brew ls --versions gnu-sed > /dev/null; then
            echo ""
            echo "Brew package gnu-sed is not installed, but required."
            read -p "Install missing package? (Y/N, default N) => " -n 1 -r
            echo ''
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install gnu-sed
            else
                ez_exit
            fi
        else
            echo "Everything's fine\!"
            echo "Continuing..."
        fi
    else
        echo "Everything's fine\!"
        echo "Continuing..."
    fi
    main_menu
done
