## k3os setup
1. Download ISO and install k3os (remaster ISO?)
1. Configure static IP address (https://www.centlinux.com/2019/05/configure-network-on-k3os-machine.html)
    ```
    sudo connmanctl services
    sudo connmanctl config ethernet_681def0b1da9_cable --ipv4 manual 192.168.2.3 255.255.255.0 192.168.2.1 --nameservers 1.1.1.1
    ```
1. Config to not deploy built in traefik

## Editing secrets
Decrypt `env.gpg` with `gpg --decrypt env.gpg > env`.

Encrypt `env` with `gpg --symmetric --cipher-algo AES256 env`.

## Bootstrapping the cluster
1. Create namespaces
   ```
   kubectl create namespace longhorn-system flux
   ```
1. Populate secrets
   ```
   ./bootstrap-secrets.sh
   ```
1. [Install Flux Helm Operator](https://docs.fluxcd.io/projects/helm-operator/en/stable/get-started/quickstart/#install-the-helm-operator)
   ```
   kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.1.0/deploy/crds.yaml
   helm repo add fluxcd https://charts.fluxcd.io
   helm upgrade -i helm-operator fluxcd/helm-operator \
    --namespace flux \
    --set helm.versions=v3
   ```
1. Install traefik
   ```
   kubectl apply -f default/traefik/helmrelease.yaml
   ```
1. Setup forward-auth and ingress for traefik
   ```
   kubectl apply -f default/traefik/traefik-forward-auth.yaml
   # ensure you wait until the let's encrypt cert was obtained
   kubectl apply -f default/traefik/traefik-ui.yaml
   ```
1. Install longhorn
   ```
   kubectl apply -f longhorn-system/longhorn.yaml
   ```
1. Restore volumes and create PV/PVC in longhorn UI
1. Apply other configs
   ```
   kubectl apply -f default/
   ```
