export OXIDIZER=${OXIDIZER:-"${HOME}/oxidizer"}
printf "📦 Installing Oxidizer\n"

###################################################
# Install Homebrew
###################################################

if test ! "$(command -v brew)"; then
    printf "📦 Homebrew not installed. Installing.\n"
    if [[ $(uname -s) = "Linux" ]] && [[ $(uname -m) = "aarch64" ]]; then
        printf "⚠️ Oxidizer doesn't support limited Linux-son-ARM yet."
        sleep 5
        exit
    elif [[ ${BREW_CN} ]]; then
        /bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

printf "⚙️ Adding Custom settings...\n"
cp -i -v ${OXIDIZER}/defaults.sh ${OXIDIZER}/custom.sh

if [[ $(uname -s) = "Darwin" ]]; then
    printf "📦 Activating Homebrew on MacOS...\n"
    if [[ $(uname -m) = "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'export PATH="/opt/homebrew/bin:$PATH"' >>~/.zshrc
    else
        eval "$(/usr/local/Homebrew/bin/brew shellenv)"
    fi
else
    printf "📦 Activating Homebrew on Linux...\n"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

brew tap "homebrew/services"
brew tap "homebrew/bundle"

###################################################
# Install Packages
###################################################

printf "📦 Installing essential Oxidizer toolchains...\n"

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
    brew install uutils-coreutils
done

###################################################
# Install Zap
###################################################

if [[ $(uname -s) = "Linux" ]]; then
    printf "📦 Adding Tap linuxbrew/fonts...\n"
    brew tap "linuxbrew/fonts"
    printf "📦 Installing Zap to Manage AppImage Packages...\n"
    curl https://raw.githubusercontent.com/srevinsaju/zap/main/install.sh | bash -s
else
    printf "📦 Adding Tap homebrew/cask-fonts...\n"
    brew tap "homebrew/cask-fonts"
fi

###################################################
# Update Shell Settings
###################################################

printf "⚙️ Configuring Shell...\n"

case ${SHELL} in
*zsh)
    brew install zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    export OX_SHELL=${HOME}/.zshrc
    ;;
*bash)
    if [[ $(bash --version | head -n1 | cut -d' ' -f4 | cut -d'.' -f1) < 5 ]]; then
        printf "📦 Installing latest Bash...\n"
        brew install bash bash-completion
    fi
    export OX_SHELL=${HOME}/.profile
    echo 'export BASH_SILENCE_DEPRECATION_WARNING=1' >>${OX_SHELL}
    ;;
esac

###################################################
# Inject Oxidizer
###################################################

printf "⚙️ Adding Oxidizer into ${OX_SHELL}...\n"

echo "# Oxidizer" >>${OX_SHELL}

if [[ -z ${OXIDIZER} ]]; then
    OXIDIZER="${HOME}/oxidizer"
    append_str='export OXIDIZER='"${OXIDIZER}"' && source '"${OXIDIZER}"'/oxidizer.sh'
else
    append_str='source '"${OXIDIZER}"'/oxidizer.sh'
fi

echo "${append_str}" >>"${OX_SHELL}"

printf "⚙️ Adding Custom settings..."
cp ${OXIDIZER}/defaults.sh ${OXIDIZER}/custom.sh

# load zoxide
sd ".* OX_STARTUP=.*" "export OX_STARTUP=1" ${OXIDIZER}/custom.sh

# set path of oxidizer
sd "source OXIDIZER=.*" "source OXIDIZER=${OXIDIZER}/oxidizer.sh" ${OX_SHELL}

###################################################
# Load Plugins
###################################################

git clone --depth=1 https://github.com/ivaquero/oxplugins-zsh.git

###################################################
# Editor
###################################################

if test ! "$(command -v nvim)"; then
    printf "⚙️ Using Vim as Default Terminal Editor"
    export EDITOR="vi"
else
    export EDITOR="nvim"
fi

printf "🎉 Oxidizer installation complete!\n"
printf "💡 Don't forget to restart your terminal and hit 'edf ox' to tweak your preferences.\n"
printf "😀 Finally, run 'upox' function to activate the plugins. Enjoy\!\n"
