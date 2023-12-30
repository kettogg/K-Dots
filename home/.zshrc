# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep
# bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/re1san/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Add Starship
eval "$(starship init zsh)"

# Alias
alias ls="ls --color=auto"
#alias l="eza"
#alias la="eza -l"
alias nf="neofetch"
alias dev="cd ~/Dev"
alias lia="cd ~/Dev/Lia"
alias v="nvim"

export PATH=/home/re1san/.local/bin:$PATH
# Julia <3
export PATH=/home/re1san/julia-1.9.4/bin:$PATH

# Plugins
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Startup
# nf
fetch

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
