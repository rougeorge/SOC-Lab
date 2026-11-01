# Troubleshooting log

Real problems hit while building this lab, with cause and fix.

| # | Symptom | Cause | Fix |
|---|---|---|---|
| 1 | `argument --resource-group/-g: expected one argument` | Cloud Shell had reset, so `$RG` and `$LOC` were empty | Re-set variables each session; keep them in `env.sh` |
| 2 | `unpack requires a buffer of 4 bytes` on `az vm create` | The literal text `<paste your public key>` was passed as the SSH key | Pass the real `.pub` contents, via a variable |
| 3 | `SkuNotAvailable` for `Standard_B1s` | B-series restricted for the subscription in Austria East | Used `az vm list-skus` with a restrictions filter and picked an unrestricted D-series size |
| 4 | Size list suggested B2s/B2ms were available | `az vm list-sizes` is deprecated and ignores subscription restrictions | Trust `az vm list-skus ... restrictions` instead |
| 5 | Only 4 vCPUs available in the region | Default regional quota on a new subscription | Request a quota increase; deallocate VMs not in use (they do not count) |
| 6 | "Allow SSH from jump box" did not actually isolate subnets | Default `AllowVnetInBound` (priority 65000) allows all VNet traffic | Added `Deny-Other-VNet-Inbound` at priority 4000 on web and ELK NSGs |
| 7 | Kibana tunnel would have been blocked by the new deny rule | The tunnel is VNet traffic from the jump box to port 5601 | Added `Allow-Kibana-From-Mgmt` at priority 120, before the deny |
| 8 | `az vm create` would have opened SSH to the internet | Azure adds a NIC-level NSG by default | Used `--nsg ""` so only the subnet NSG controls access |
| 9 | `permission denied ... /var/run/docker.sock` | Docker group membership only applies to new login sessions | Log out and back in (or `newgrp docker`) |
| 10 | Files created in `/root` instead of the user's home | Worked as root by mistake; `~` expanded to `/root` | Moved files back, used `sudo` per command instead of a root shell |
| 11 | `ssh-keygen` target blocked | Docker had created the missing bind-mount path as a root-owned directory | Removed it and generated the key before running the container |
| 12 | `Microsoft.Network` not registered | First use of a resource provider on a new subscription | Waited for automatic registration (1 to 3 minutes) |
| 13 | `ReadOnlyDisabledSubscription` | Free credit expired, so the subscription was disabled | Upgrade to pay-as-you-go, or rebuild elsewhere; configs are saved in this repo |

## Takeaways

- Script everything. Cloud Shell state is disposable.
- Check quotas and SKU restrictions before designing the topology.
- Read default firewall rules; the defaults are permissive inside a VNet.
- Never trust a third-party image with credentials. Build from an official base.
