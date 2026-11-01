# Jump box setup

Run on the jump box after first SSH login.

```bash
# Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER      # log out and back in to apply

# Key used to reach the other VMs (stays on the jump box, no passphrase for unattended Ansible)
ssh-keygen -t ed25519 -f ~/.ssh/ansible-key -N ""
cat ~/.ssh/ansible-key.pub          # goes into ANSIBLE_PUBLIC_KEY in env.sh

# Build and run the Ansible container
mkdir -p ~/ansible && cd ~/ansible  # put the Dockerfile here
docker build -t my-ansible .
docker run -it --rm \
  -v ~/ansible:/ansible \
  -v ~/.ssh/ansible-key:/root/.ssh/id_ed25519:ro \
  my-ansible
```

Create `~/.ssh/ansible-key` **before** the first `docker run`. If the bind-mount source
does not exist, Docker creates it as a root-owned directory and `ssh-keygen` then fails.
