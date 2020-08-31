## k3os setup
1. Download ISO and install k3os
1. Configure static IP address (https://www.centlinux.com/2019/05/configure-network-on-k3os-machine.html)
    ```
    sudo connmanctl services
    sudo connmanctl config ethernet_681def0b1da9_cable --ipv4 manual 192.168.2.4 255.255.255.0 192.168.2.1 --nameservers 1.1.1.1
    ```
1. Update `/var/lib/rancher/k3os/config.yaml` with [server config](k3os/config.yaml)

## Editing secrets
Decrypt `env.gpg` with `gpg --decrypt env.gpg > env`.

Encrypt `env` with `gpg --symmetric --cipher-algo AES256 env`.

## Bootstrapping the cluster
1. Create namespaces
   ```
   kubectl create namespace flux
   ```
1. Populate secrets
   ```
   ./bootstrap-secrets.sh
   ```
1. [Install Flux Helm Operator](https://docs.fluxcd.io/projects/helm-operator/en/stable/get-started/quickstart/#install-the-helm-operator)
   ```
   kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/1.2.0/deploy/crds.yaml
   helm repo add fluxcd https://charts.fluxcd.io
   helm upgrade -i helm-operator fluxcd/helm-operator \
    --namespace flux \
    --set helm.versions=v3
   ```
1. Create volumes
   ```
   kubectl apply -f default/volumes/pvc.yaml
   kubectl apply -f default/volumes/restorejobs.yaml
   ```
1. Restore volumes and wait for them to finish
   ```
   kubectl create job --from=cronjob/esphome-restic-restore esphome-restore
   kubectl create job --from=cronjob/homeassistant-restic-restore homeassistant-restore
   kubectl create job --from=cronjob/minecraft-restic-restore minecraft-restore
   kubectl create job --from=cronjob/plex-restic-restore plex-restore
   kubectl create job --from=cronjob/qbittorrent-restic-restore qbittorrent-restore
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
1. Apply other configs
   ```
   kubectl apply -f default/
   ```
