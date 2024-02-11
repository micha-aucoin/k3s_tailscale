alias ssha='eval $(ssh-agent -s) && ssh-add ~/.ssh/ansible-vagrant'

alias k="kubectl"
alias kns="kubectl ns"
alias kctx="kubectl ctx"

alias lslinode="curl -s https://api.linode.com/v4/linode/types | jq '.data[] | {id: .id, label: .label, memory: .memory, disk: .disk, price_hourly: .price.hourly, price_monthly: .price.monthly}'"
