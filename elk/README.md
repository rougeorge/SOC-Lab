# ELK server setup

Run on `elk-vm` (reached from the jump box).

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker $USER      # log out and back in to apply

# Elasticsearch refuses to start without this
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/99-elasticsearch.conf

mkdir -p ~/elk && cd ~/elk         # put docker-compose.yml and .env here
cp .env.example .env
docker compose up -d
docker compose ps
curl -s "localhost:9200/_cluster/health?pretty"   # expect "status" : "green"
```

## Reaching Kibana (never exposed to the internet)

From your own computer, open an SSH tunnel through the jump box and leave it running:

```bash
ssh -i ~/.ssh/soc-lab-key -L 5601:<ELK_PRIVATE_IP>:5601 azureadmin@<JUMPBOX_PUBLIC_IP>
```

Then browse to `http://localhost:5601`.
