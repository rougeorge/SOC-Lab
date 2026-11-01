#!/usr/bin/env bash
# Creates the jump box: static public IP + Ubuntu VM in mgmt-subnet, SSH key login only.
# Usage: source env.sh && bash create-jumpbox.sh
set -euo pipefail
: "${RG:?}" "${LOC:?}" "${PC_PUBLIC_KEY:?}" "${JUMPBOX_SIZE:?}"

az network public-ip create -g "$RG" -l "$LOC" -n jumpbox-pip \
  --sku Standard --allocation-method Static -o none

# --nsg "" stops Azure from adding its own NIC-level NSG that opens SSH to the internet.
# Access is controlled only by mgmt-nsg on the subnet.
az vm create -g "$RG" -l "$LOC" -n jumpbox \
  --image Ubuntu2204 --size "$JUMPBOX_SIZE" \
  --vnet-name soc-vnet --subnet mgmt-subnet \
  --public-ip-address jumpbox-pip \
  --admin-username azureadmin \
  --authentication-type ssh \
  --ssh-key-values "$PC_PUBLIC_KEY" \
  --nsg "" -o table

echo "Jump box public IP:"
az network public-ip show -g "$RG" -n jumpbox-pip --query ipAddress -o tsv
