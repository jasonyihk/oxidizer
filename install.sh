export OXIDIZER=${OXIDIZER:-"${HOME}/Workspace/jasonyihk/oxidizer"}
printf "📦 Installing Oxidizer\n"

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

append_str='source '"${OXIDIZER}"'/oxidizer.sh'
echo "${append_str}" >>"${OX_SHELL}"

# load zoxide
sd ".* OX_STARTUP=.*" "export OX_STARTUP=1" ${OXIDIZER}/defaults.sh

# set path of oxidizer
sd "source OXIDIZER=.*" "source OXIDIZER=${OXIDIZER}/oxidizer.sh" ${OX_SHELL}

###################################################
# Editor
###################################################

if test "$(command -v hx)"; then
    printf "⚙️ Using Helix as Default Terminal Editor"
    export EDITOR="nvim"
elif test "$(command -v nvim)"; then
    printf "⚙️ Using nvim as Default Terminal Editor"
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi

printf "🎉 Oxidizer installation complete!\n"
printf "💡 Don't forget to restart your terminal and hit 'edf ox' to tweak your preferences.\n"
printf "😀 Finally, run 'upox' function to activate the plugins. Enjoy\!\n"
