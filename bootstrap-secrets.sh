set -e

eval "$(gpg --decrypt env.gpg)"

kubectl create secret generic cloudflare-ddns \
    --from-literal=API_KEY="${CLOUDFLARE_DDNS_KEY}"
kubectl create secret generic acme-cloudflare \
    --from-literal=CLOUDFLARE_EMAIL="${CLOUDFLARE_ACME_EMAIL}" \
    --from-literal=CLOUDFLARE_API_KEY="${CLOUDFLARE_ACME_KEY}"
kubectl create secret generic restic-secrets \
    --from-literal=AWS_ACCESS_KEY_ID="${RESTIC_AWS_ACCESS_KEY_ID}" \
    --from-literal=AWS_SECRET_ACCESS_KEY="${RESTIC_AWS_SECRET_ACCESS_KEY}" \
    --from-literal=RESTIC_PASSWORD="${RESTIC_PASSWORD}"
kubectl create secret generic traefik-forward-auth-secrets \
    --from-literal=traefik-forward-auth-google-client-id="${GOOGLE_CLIENT_ID}" \
    --from-literal=traefik-forward-auth-google-client-secret="${GOOGLE_CLIENT_SECRET}" \
    --from-literal=traefik-forward-auth-secret="${FORWARD_AUTH_SECRET}"
kubectl create secret generic frigate-rtsp \
    --from-literal=FRIGATE_BACK_PASSWORD="${FRIGATE_RTSP_PASSWORD}"
kubectl create secret generic postgres-init-secrets \
    --from-literal=01-set-passwords.sql="ALTER ROLE hass WITH PASSWORD '${POSTGRESQL_HASS_PASSWORD}';"