export OXIDIZER=${OXIDIZER:-"${HOME}/Workspace/jasonyihk/oxidizer"}
export OXIDIZER_PLUGINS=${OXIDIZER_PLUGINS:-"${HOME}/Workspace/jasonyihk/oxplugins-zsh"}

##########################################################
# Oxidizer Configuration Files
##########################################################

# plugins
declare -A OX_OXYGEN=(
    [oxd]=${OXIDIZER}/defaults.sh
    [oxwz]=${OXIDIZER}/defaults/wezterm.lua
    #[oxpx]=${OXIDIZER}/defaults/verge.yaml
    [oxpm]=${OXIDIZER_PLUGINS}/ox-macos.sh
    [oxpd]=${OXIDIZER_PLUGINS}/ox-debians.sh
    [oxpb]=${OXIDIZER_PLUGINS}/ox-brew.sh
    [oxpg]=${OXIDIZER_PLUGINS}/ox-git.sh
    [oxpc]=${OXIDIZER_PLUGINS}/ox-conda.sh
    [oxpbw]=${OXIDIZER_PLUGINS}/ox-bitwarden.sh
    [oxpcn]=${OXIDIZER_PLUGINS}/ox-conan.sh
    [oxpct]=${OXIDIZER_PLUGINS}/ox-container.sh
    [oxpes]=${OXIDIZER_PLUGINS}/ox-espanso.sh
    [oxphx]=${OXIDIZER_PLUGINS}/ox-helix.sh
    [oxpjl]=${OXIDIZER_PLUGINS}/ox-julia.sh
    [oxpjn]=${OXIDIZER_PLUGINS}/ox-jupyter.sh
    [oxpnj]=${OXIDIZER_PLUGINS}/ox-node.sh
    [oxppd]=${OXIDIZER_PLUGINS}/ox-podman.sh
    [oxppu]=${OXIDIZER_PLUGINS}/ox-pueue.sh
    [oxprs]=${OXIDIZER_PLUGINS}/ox-rust.sh
    [oxptl]=${OXIDIZER_PLUGINS}/ox-texlive.sh
    [oxput]=${OXIDIZER_PLUGINS}/ox-utils.sh
    [oxpvs]=${OXIDIZER_PLUGINS}/ox-vscode.sh
    [oxpzj]=${OXIDIZER_PLUGINS}/ox-zellij.sh
    [oxpfm]=${OXIDIZER_PLUGINS}/ox-formats.sh
    [oxpwr]=${OXIDIZER_PLUGINS}/ox-weather.sh
    [oxpns]=${OXIDIZER_PLUGINS}/ox-notes.sh
)

##########################################################
# System Configuration Files
##########################################################

declare -A OX_ELEMENT=(
    [ox]=${OXIDIZER}/defaults.sh
    [vi]=${HOME}/.vimrc
    #[px]=${HOME}/.config/clash-verge/verge.yaml
)

declare -A OX_OXIDE

##########################################################
# Load Plugins
##########################################################

# load system plugin
case $(uname -a) in
*Darwin*)
    . ${OX_OXYGEN[oxpm]}
    ;;
*Ubuntu* | *Debian* | *WSL*)
    . ${OX_OXYGEN[oxpd]}
    ;;
esac

# load custom plugins
declare -a OX_PLUGINS

. ${OX_ELEMENT[ox]}

for plugin in ${OX_PLUGINS[@]}; do
    . ${OX_OXYGEN[$plugin]}
done

declare -a OX_CORE_PLUGINS
OX_CORE_PLUGINS=(oxpb oxput oxppu)

# load core plugins
for core_plugin in ${OX_CORE_PLUGINS[@]}; do
    . ${OX_OXYGEN[$core_plugin]}
done

##########################################################
# Shell Settings
##########################################################

export SHELLS=/private/etc/shells

# use rust alternatives
alias ls="lsd"
alias cat="bat"
alias du="dust"

case ${SHELL} in
*zsh)
    OX_ELEMENT[zs]=${HOME}/.zshrc
    OX_ELEMENT[zshst]=${HOME}/.zsh_history
    OX_OXIDE[bkzs]=${OX_BACKUP}/shell/.zshrc
    ;;
*bash)
    [bs]=${HOME}/.bash_profile
    [bshst]=${HOME}/.bash_history
    OX_OXIDE[bkbs]=${OX_BACKUP}/shell/.bash_profile
    ;;
esac

OX_OXIDE[bkvi]=${OX_BACKUP}/shell/.vimrc

##########################################################
# Oxidizer Management
##########################################################

# update all packages
up_all() {
    for obj in ${OX_UPDATE_PROG[@]}; do
        eval up_$obj
    done
}

# backup package lists
back_all() {
    for obj in ${OX_BACKUP_PROG[@]}; do
        eval back_$obj
    done
}

# export configurations
epall() {
    for obj in ${OX_EXPORT_FILE[@]}; do
        epf $obj
    done
}

# import configurations
ipall() {
    for obj in ${OX_IMPORT_FILE[@]}; do
        ipf $obj
    done
}

iiox() {
    echo "Installing Required packages...\n"
    for pkg in $(cat ${OXIDIZER}/defaults/Brewfile.txt); do
        case $pkg in
        ripgrep)
            cmd='rg'
            ;;
        bottom)
            cmd='btm'
            ;;
        tealdear)
            cmd='tldr'
            ;;
        zoxide)
            cmd='z'
            ;;
        *)
            cmd=$pkg
            ;;
        esac
        if test ! "$(command -v $cmd)"; then
            brew install $pkg
        fi
    done
}

# update Oxidizer
upox() {
    cd ${OXIDIZER}
    echo "Updating Oxidizer...\n"
    git fetch origin master
    git reset --hard origin/master

    if [ ! -d ${OXIDIZER_PLUGINS} ]; then
        echo "\n\nCloning Oxidizer Plugins...\n"
        git clone --depth=1 https://github.com/ivaquero/oxplugins-zsh.git
    else
        echo "\n\nUpdating Oxidizer Plugins...\n"
        cd ${OXIDIZER_PLUGINS}
        git fetch origin main
        git reset --hard origin/main
    fi

    cd ${OXIDIZER}
    local ox_change=$(git diff defaults.sh)
    if [ -n $ox_change ]; then
        echo "\n\nDefaults changed, don't forget to update your custom.sh accordingly...\n"
        echo "Compare the difference using 'edf oxd'"
    fi
    cd ${HOME}
}

##########################################################
# Starship
##########################################################

if test "$(command -v starship)"; then
    # system files
    export STARSHIP_CONFIG=${HOME}/.config/starship.toml
    OX_ELEMENT[ss]=${STARSHIP_CONFIG}
    # backup files
    OX_OXIDE[ss]=${OX_BACKUP}/shell/starship.toml

    case ${SHELL} in
    *zsh)
        eval "$(starship init zsh)"
        ;;
    *bash)
        eval "$(starship init bash)"
        ;;
    esac
fi

if [[ ${OX_STARTUP} ]]; then
    startup
fi
