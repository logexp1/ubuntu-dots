# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Download zinit if it's not there yet
ZINIT_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# add in powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# add in snippets - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
zinit snippet OMZP::git
zinit snippet OMZP::kubectl

# load completions, this must be before loading fzf-tab
autoload -U compinit && compinit

zinit cdreplay -q

# add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# zinit light zsh-users/zsh-history-substring-search
# zinit ice wait atload'_history_substring_search_config'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# custom variables
export PATH=$PATH:/usr/local/go/bin:$HOME/.local/bin
alias k=$HOME/build/k9s/execs/k9s
alias ls="eza -a"
alias ll="eza -al --color=always --icons --group-directories-first"

# keybindings
bindkey "\e[A" history-search-backward
bindkey "\e[B" history-search-forward

# history
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
