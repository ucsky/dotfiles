###############################################################################
# Git aliases
###############################################################################
alias gs='git status -sb'
alias gl='git lg'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gbr='git branch -vv'
alias gundo='git reset HEAD~1 --mixed'
alias gpush='git push'
alias gpull='git pull'

###############################################################################
# General aliases
###############################################################################
# Disk usage on all files (including dotfiles), sorted
alias dusort='du -sh .[!.]* * | sort -h'
