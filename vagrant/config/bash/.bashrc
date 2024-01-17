export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

source <(kubectl completion bash)
source <(helm completion bash)
source <(tkn completion bash)
complete -o default -F __start_kubectl k

git_prompt() {
    local format_string="$1"
    local branch="$(git symbolic-ref HEAD 2> /dev/null | cut -d'/' -f3-)"
    local branch_truncated="${branch:0:30}"
    if (( ${#branch} > ${#branch_truncated} )); then
        branch="${branch_truncated}..."
    fi
    [ -n "${branch}" ] && printf "$format_string" "$branch"
}

condaenv_prompt() {
    local format_string="$1"
    local cenv="${CONDA_DEFAULT_ENV##*/}"
    [ -n "${cenv}" ] && printf "$format_string" "$cenv"
}

update_prompt() {
    PS1='$(condaenv_prompt "|\[\033[01;32m\]%s\[\033[00m\]")'
    PS1+='$(git_prompt "|\[\033[01;33m\]%s\[\033[00m\]")'
    PS1+="|\A \W "
    PS1+="$(kube_ps1) "
    PS1+="\[\033[31m\]➜  \[\033[0m\]"
}
source /usr/local/bin/kube-ps1
PROMPT_COMMAND="update_prompt; $PROMPT_COMMAND"

# --- PERSONAL NOTES ---
mk_conda() {
    conda create -n $1 python=3.10
}

conda_rm() {
    conda remove -n $1 --all
}