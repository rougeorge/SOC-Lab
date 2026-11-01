#!/usr/bin/env bash
# Creates the ELK server: no public IP, reachable only from the jump box.
# Only the jump box's key (ANSIBLE_PUBLIC_KEY) is installed, so the jump box is the only way in.
# Usage: source env.sh && bash create-elk-vm.sh
set -euo pipefail
: "${RG:?}" "${LOC:?}" "${ANSIBLE_PUBLIC_KEY:?}" "${ELK_SIZE:?}"

az vm create -g "$RG" -l "$LOC" -n elk-vm \
  --image Ubuntu2204 --size "$ELK_SIZE" \
  --vnet-name soc-vnet --subnet elk-subnet \
  --public-ip-address "" \
  --admin-username azureadmin \
  --authentication-type ssh \
  --ssh-key-values "$ANSIBLE_PUBLIC_KEY" \
  --os-disk-size-gb 64 \
  --nsg "" -o table

echo "ELK private IP:"
az vm show -d -g "$RG" -n elk-vm --query privateIps -o tsv
