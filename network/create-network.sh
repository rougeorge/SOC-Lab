#!/usr/bin/env bash
# Creates the resource group, virtual network, three subnets and three NSGs.
# Usage: source env.sh && bash create-network.sh
set -euo pipefail
: "${RG:?set RG}" "${LOC:?set LOC}" "${MYIP:?set MYIP}"

echo "== Resource group =="
az group create -n "$RG" -l "$LOC" -o none

echo "== Virtual network and subnets =="
az network vnet create -g "$RG" -l "$LOC" -n soc-vnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name mgmt-subnet --subnet-prefix 10.0.1.0/24 -o none
az network vnet subnet create -g "$RG" --vnet-name soc-vnet \
  --name web-subnet --address-prefix 10.0.2.0/24 -o none
az network vnet subnet create -g "$RG" --vnet-name soc-vnet \
  --name elk-subnet --address-prefix 10.0.3.0/24 -o none

echo "== mgmt-nsg (jump box): SSH from my IP only =="
az network nsg create -g "$RG" -l "$LOC" -n mgmt-nsg -o none
az network nsg rule create -g "$RG" --nsg-name mgmt-nsg \
  --name Allow-SSH-MyIP --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes "$MYIP" --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 22 -o none

echo "== web-nsg: SSH from mgmt subnet, HTTP from my IP, deny other VNet traffic =="
az network nsg create -g "$RG" -l "$LOC" -n web-nsg -o none
az network nsg rule create -g "$RG" --nsg-name web-nsg \
  --name Allow-SSH-From-Mgmt --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes 10.0.1.0/24 --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 22 -o none
az network nsg rule create -g "$RG" --nsg-name web-nsg \
  --name Allow-HTTP-MyIP --priority 110 \
  --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes "$MYIP" --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 80 -o none
az network nsg rule create -g "$RG" --nsg-name web-nsg \
  --name Deny-Other-VNet-Inbound --priority 4000 \
  --direction Inbound --access Deny --protocol '*' \
  --source-address-prefixes VirtualNetwork --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges '*' -o none

echo "== elk-nsg: SSH + Kibana from mgmt, Beats from web, deny other VNet traffic =="
az network nsg create -g "$RG" -l "$LOC" -n elk-nsg -o none
az network nsg rule create -g "$RG" --nsg-name elk-nsg \
  --name Allow-SSH-From-Mgmt --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes 10.0.1.0/24 --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 22 -o none
az network nsg rule create -g "$RG" --nsg-name elk-nsg \
  --name Allow-Beats-From-Web --priority 110 \
  --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes 10.0.2.0/24 --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 5044 9200 -o none
az network nsg rule create -g "$RG" --nsg-name elk-nsg \
  --name Allow-Kibana-From-Mgmt --priority 120 \
  --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes 10.0.1.0/24 --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 5601 -o none
az network nsg rule create -g "$RG" --nsg-name elk-nsg \
  --name Deny-Other-VNet-Inbound --priority 4000 \
  --direction Inbound --access Deny --protocol '*' \
  --source-address-prefixes VirtualNetwork --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges '*' -o none

echo "== Attach each NSG to its subnet =="
az network vnet subnet update -g "$RG" --vnet-name soc-vnet \
  --name mgmt-subnet --network-security-group mgmt-nsg -o none
az network vnet subnet update -g "$RG" --vnet-name soc-vnet \
  --name web-subnet --network-security-group web-nsg -o none
az network vnet subnet update -g "$RG" --vnet-name soc-vnet \
  --name elk-subnet --network-security-group elk-nsg -o none

echo "== Verify =="
az network vnet subnet list -g "$RG" --vnet-name soc-vnet \
  --query "[].{subnet:name, nsg:networkSecurityGroup.id}" -o table
