#!/usr/bin/env bash

set -Eeuo pipefail

slot="${1:-}"
image_ref="${2:-}"
deploy_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
env_file="$deploy_root/deploy.env"
compose_file="$deploy_root/compose.yml"

if [[ "$slot" != "staging" && "$slot" != "production" ]]; then
    echo "Deployment slot must be staging or production." >&2
    exit 2
fi

if [[ ! "$image_ref" =~ ^ghcr\.io/[a-z0-9._/-]+(:[A-Za-z0-9._-]+|@sha256:[a-f0-9]{64})$ ]]; then
    echo "IMAGE_REF must be a valid GHCR tag or digest." >&2
    exit 2
fi

if [[ ! -f "$env_file" ]]; then
    echo "Missing $env_file. Copy deploy.env.example to deploy.env and fill the server values first." >&2
    exit 2
fi

command -v docker >/dev/null || { echo "docker is required." >&2; exit 2; }
command -v curl >/dev/null || { echo "curl is required." >&2; exit 2; }
docker compose version >/dev/null

if [[ "$slot" == "production" ]]; then
    service="api-production"
    image_key="PRODUCTION_IMAGE_REF"
    domain_key="PRODUCTION_DOMAIN"
else
    service="api-staging"
    image_key="STAGING_IMAGE_REF"
    domain_key="STAGING_DOMAIN"
fi

read_env_value() {
    local key="$1"
    awk -F= -v key="$key" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$env_file"
}

write_env_value() {
    local key="$1"
    local value="$2"
    local output
    output="$(mktemp "$deploy_root/deploy.env.XXXXXX")"
    awk -v key="$key" -v value="$value" '
        BEGIN { updated = 0 }
        index($0, key "=") == 1 { print key "=" value; updated = 1; next }
        { print }
        END { if (!updated) print key "=" value }
    ' "$env_file" > "$output"
    chmod --reference="$env_file" "$output" 2>/dev/null || chmod 600 "$output"
    mv -- "$output" "$env_file"
}

compose() {
    docker compose --project-name labx --env-file "$env_file" --file "$compose_file" "$@"
}

previous_image_ref="$(read_env_value "$image_key")"
domain="$(read_env_value "$domain_key")"
if [[ -z "$domain" || "$domain" == *example.com ]]; then
    echo "$domain_key must contain the real DNS name." >&2
    exit 2
fi

previous_container_id="$(compose ps --quiet "$service" 2>/dev/null || true)"
backup_file="$(mktemp "$deploy_root/deploy.env.backup.XXXXXX")"
cp -- "$env_file" "$backup_file"

rollback() {
    echo "Health check failed; rolling $slot back to $previous_image_ref." >&2
    cp -- "$backup_file" "$env_file"
    if [[ -n "$previous_container_id" ]]; then
        compose up --detach --no-deps "$service"
    else
        compose rm --force --stop "$service" >/dev/null 2>&1 || true
    fi
}

trap 'rm -f -- "$backup_file"' EXIT

write_env_value "$image_key" "$image_ref"
compose config --quiet
compose pull "$service" caddy
compose up --detach --no-deps "$service"
compose up --detach --no-deps caddy

health_url="https://${domain}/health/ready"
for _ in $(seq 1 30); do
    if [[ "$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --max-time 5 "$health_url" || true)" == "200" ]]; then
        echo "Deployment succeeded: $slot -> $image_ref"
        echo "Health check passed: $health_url"
        exit 0
    fi
    sleep 2
done

rollback
exit 1
