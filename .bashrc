#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ls='lsd'

# PS1="\[\033[91m\][\h] \[\033[35m\](\u) \[\033[37m\]\[\033[34m\]\w \[\033[0m\]"
PS1="\033[91m󰣇 \h\033[35m󰀄 \033[35m\u \[\033[37m\]\[\033[34m\]󰉋 \w \[\033[0m\]"
neofetch

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.nix-profile/bin:$PATH"
