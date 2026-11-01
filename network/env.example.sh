# Copy to env.sh (git-ignored), fill in real values, then: source env.sh
export RG=soc-lab-rg
export LOC=austriaeast

# Your current public IP (look it up from your own computer, not Cloud Shell)
export MYIP=<YOUR_PUBLIC_IP>

# Public key of your PC (contents of ~/.ssh/soc-lab-key.pub)
export PC_PUBLIC_KEY="ssh-ed25519 AAAA... you@your-pc"

# Public key generated ON the jump box (contents of ~/.ssh/ansible-key.pub)
export ANSIBLE_PUBLIC_KEY="ssh-ed25519 AAAA... azureadmin@jumpbox"

# VM sizes. B-series was restricted on my subscription in Austria East,
# so I used D-series. Check yours with:
#   az vm list-skus -l $LOC --resource-type virtualMachines \
#     --query "[?length(restrictions)==\`0\`].name" -o tsv
export JUMPBOX_SIZE=Standard_D2ls_v6   # 2 vCPU, 4 GB
export ELK_SIZE=Standard_D2s_v6        # 2 vCPU, 8 GB
