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
conde() {
    conda deactivate
}
mkconda() {
    conda create -n $1 python=3.11
}
rmconda() {
    conda remove -n $1 --all
}
lsconda() {
    conda env list
}

# this is a workaround when k3s_server_manifests_templates is not working.
helminstall-tailscale-op() {
  # Check if TAILSCALE_CLIENT_ID and TAILSCALE_CLIENT_SECRET are set
  if [ -z "$TAILSCALE_CLIENT_ID" ] || [ -z "$TAILSCALE_CLIENT_SECRET" ]; then
    echo "Error: TAILSCALE_CLIENT_ID and TAILSCALE_CLIENT_SECRET must be set."
    return 1  # Return with a non-zero status if variables are not set
  fi

  # Create the .kube directory if it doesn't exist
  mkdir -p ~/.kube

  # Move and change ownership of the kube config file
  if [ -f /etc/rancher/k3s/k3s.yaml ]; then
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $(id -un):$(id -gn) ~/.kube/config
  else
    echo "Error: Kubernetes config file not found."
    return 1
  fi

  # Install Helm if it is not already installed
  if ! command -v helm &> /dev/null; then
    echo "Helm not found, installing..."
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
  else
    echo "Helm is already installed."
  fi

  # Proceed with Helm command
  helm upgrade --install tailscale-operator tailscale-operator \
    --repo https://pkgs.tailscale.com/helmcharts \
    --create-namespace --namespace tailscale \
    --set-string oauth.clientId="$TAILSCALE_CLIENT_ID" \
    --set-string oauth.clientSecret="$TAILSCALE_CLIENT_SECRET" \
    --set-string apiServerProxyConfig.mode="true" \
    --wait
}


helminstall-rancher() {
  helm upgrade --install cert-manager cert-manager \
    --repo https://charts.jetstack.io \
    --create-namespace --namespace cert-manager \
    --set installCRDs=true \
    &&

  helm upgrade --install rancher rancher \
    --repo https://releases.rancher.com/server-charts/stable \
    --namespace cattle-system --create-namespace \
    --set hostname=rancher.my.org \
    --set bootstrapPassword=admin \
    &&

  kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tailscale-rancher
  namespace: cattle-system
  annotations:
    tailscale.com/funnel: "true"
spec:
  defaultBackend:
    service:
      name: rancher
      port:
        number: 80
  ingressClassName: tailscale
  tls:
  - hosts:
    - "ranch"
EOF
}

