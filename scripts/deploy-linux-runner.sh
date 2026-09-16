#!/usr/bin/env bash

set -Eeuo pipefail

required_variables=(
    DEPLOY_SLOT
    DEPLOY_HOST
    DEPLOY_USER
    DEPLOY_PATH
    DEPLOY_SSH_KEY
    DEPLOY_KNOWN_HOSTS
)

for variable_name in "${required_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "Missing required deployment value: $variable_name" >&2
        exit 2
    fi
done

sync_only="${SYNC_ONLY:-false}"
if [[ "$sync_only" != "true" && "$sync_only" != "false" ]]; then
    echo "SYNC_ONLY must be true or false." >&2
    exit 2
fi
if [[ "$sync_only" != "true" && -z "${IMAGE_REF:-}" ]]; then
    echo "Missing required deployment value: IMAGE_REF" >&2
    exit 2
fi

deploy_port="${DEPLOY_PORT:-22}"
if [[ ! "$deploy_port" =~ ^[0-9]+$ ]] || (( deploy_port < 1 || deploy_port > 65535 )); then
    echo "DEPLOY_PORT must be between 1 and 65535." >&2
    exit 2
fi
if [[ ! "$DEPLOY_HOST" =~ ^[A-Za-z0-9.-]+$ ]]; then
    echo "DEPLOY_HOST must be a DNS name or IPv4 address." >&2
    exit 2
fi
if [[ ! "$DEPLOY_USER" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]]; then
    echo "DEPLOY_USER contains unsupported characters." >&2
    exit 2
fi
if [[ ! "$DEPLOY_PATH" =~ ^/[A-Za-z0-9._/-]+$ ]]; then
    echo "DEPLOY_PATH must be an absolute Linux path without spaces." >&2
    exit 2
fi
if [[ "$DEPLOY_SLOT" != "staging" && "$DEPLOY_SLOT" != "production" ]]; then
    echo "DEPLOY_SLOT must be staging or production." >&2
    exit 2
fi
if [[ "$sync_only" != "true" && ! "$IMAGE_REF" =~ ^ghcr\.io/[a-z0-9._/-]+(:[A-Za-z0-9._-]+|@sha256:[a-f0-9]{64})$ ]]; then
    echo "IMAGE_REF must be a valid GHCR tag or digest." >&2
    exit 2
fi

temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "$temporary_directory"' EXIT
private_key="$temporary_directory/id_ed25519"
known_hosts="$temporary_directory/known_hosts"
printf '%s\n' "$DEPLOY_SSH_KEY" | tr -d '\r' > "$private_key"
printf '%s\n' "$DEPLOY_KNOWN_HOSTS" | tr -d '\r' > "$known_hosts"
chmod 600 "$private_key" "$known_hosts"

ssh_options=(
    -i "$private_key"
    -p "$deploy_port"
    -o BatchMode=yes
    -o IdentitiesOnly=yes
    -o StrictHostKeyChecking=yes
    -o "UserKnownHostsFile=$known_hosts"
)
scp_options=(
    -i "$private_key"
    -P "$deploy_port"
    -o BatchMode=yes
    -o IdentitiesOnly=yes
    -o StrictHostKeyChecking=yes
    -o "UserKnownHostsFile=$known_hosts"
)
remote="$DEPLOY_USER@$DEPLOY_HOST"

printf -v create_directory_command 'mkdir -p %q' "$DEPLOY_PATH"
ssh "${ssh_options[@]}" "$remote" "$create_directory_command"
scp "${scp_options[@]}" \
    deploy/linux/compose.yml \
    deploy/linux/Caddyfile \
    deploy/linux/deploy.env.example \
    deploy/linux/deploy.sh \
    "$remote:$DEPLOY_PATH/"

if [[ "$sync_only" == "true" ]]; then
    echo "Deployment files uploaded to $remote:$DEPLOY_PATH. No container was changed."
    exit 0
fi

printf -v deploy_command 'cd %q && bash ./deploy.sh %q %q' "$DEPLOY_PATH" "$DEPLOY_SLOT" "$IMAGE_REF"
ssh "${ssh_options[@]}" "$remote" "$deploy_command"
