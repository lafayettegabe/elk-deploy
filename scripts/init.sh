#!/bin/bash
# Ensure Docker config dir exists even if Cloud-init splits this script
mkdir -p /etc/docker

set -xe

# -----------------------------------------------------------------------------
# EBS volume setup (/dev/nvme1n1 → /mnt/ebs)
# -----------------------------------------------------------------------------
for i in $(seq 1 10); do
  [[ -e /dev/nvme1n1 ]] && break
  echo "Waiting for /dev/nvme1n1 ($i/10)…"
  sleep 2
done
[ -b /dev/nvme1n1 ] || { echo "Device /dev/nvme1n1 not found"; exit 1; }
blkid /dev/nvme1n1 || mkfs.ext4 /dev/nvme1n1
mkdir -p /mnt/ebs
mount /dev/nvme1n1 /mnt/ebs
echo "/dev/nvme1n1 /mnt/ebs ext4 defaults,nofail 0 2" >> /etc/fstab

# -----------------------------------------------------------------------------
# Configure Docker to use EBS for all data
# -----------------------------------------------------------------------------
mkdir -p /mnt/ebs/docker-data
cat >/etc/docker/daemon.json <<EOF
{ "data-root": "/mnt/ebs/docker-data" }
EOF

# Install Docker prerequisites
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release \
                   apt-transport-https software-properties-common git jq openssl

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list >/dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker

# -----------------------------------------------------------------------------
# Deploy ELK stack
# -----------------------------------------------------------------------------
cd /home/ubuntu
git clone https://github.com/lafayettegabe/docker-elk.git
chown -R ubuntu:ubuntu docker-elk
cd docker-elk

# Generate encryption keys
ENCRYPTION_KEY=$(openssl rand -hex 32)
ENCRYPTED_SAVED_OBJECTS_KEY=$(openssl rand -hex 32)
REPORTING_KEY=$(openssl rand -hex 32)

# Inject settings into kibana.yml
cat >> kibana/config/kibana.yml <<EOF

# ←— added by init.sh
server.publicBaseUrl: "https://${monitoring_url}"
xpack.security.encryptionKey: "$${ENCRYPTION_KEY}"
xpack.encryptedSavedObjects.encryptionKey: "$${ENCRYPTED_SAVED_OBJECTS_KEY}"
xpack.reporting.encryptionKey: "$${REPORTING_KEY}"
EOF

docker compose up setup
docker compose -f docker-compose.yml up -d
echo "Waiting for Kibana to start…"
sleep 30

# -----------------------------------------------------------------------------
# Reset built-in passwords
# -----------------------------------------------------------------------------
ELASTIC_PW=$(docker compose exec -T elasticsearch \
  bin/elasticsearch-reset-password --batch --user elastic | awk '/New value:/ {print $3}')
LOGSTASH_PW=$(docker compose exec -T elasticsearch \
  bin/elasticsearch-reset-password --batch --user logstash_internal | awk '/New value:/ {print $3}')
KIBANA_PW=$(docker compose exec -T elasticsearch \
  bin/elasticsearch-reset-password --batch --user kibana_system | awk '/New value:/ {print $3}')

# Update .env with the new passwords
sed -i "s|^ELASTIC_PASSWORD=.*|ELASTIC_PASSWORD='$${ELASTIC_PW}'|" .env
sed -i "s|^LOGSTASH_INTERNAL_PASSWORD=.*|LOGSTASH_INTERNAL_PASSWORD='$${LOGSTASH_PW}'|" .env
sed -i "s|^KIBANA_SYSTEM_PASSWORD=.*|KIBANA_SYSTEM_PASSWORD='$${KIBANA_PW}'|" .env

docker compose up -d elasticsearch

sleep 300

docker compose up -d logstash kibana

sleep 300

docker compose \
  -f docker-compose.yml \
  -f extensions/fleet/fleet-compose.yml \
  -f extensions/fleet/agent-apmserver-compose.yml \
  up -d fleet-server apm-server


# -----------------------------------------------------------------------------
# Deploy elk_notify and send credentials to Discord
# -----------------------------------------------------------------------------
cd /home/ubuntu
git clone https://github.com/lafayettegabe/elk_notify.git
chown -R ubuntu:ubuntu elk_notify
cd elk_notify

cat > .env <<EOF
DISCORD_WEBHOOK_URL=${discord_webhook_url}
MONITORING_URL=${monitoring_url}
EOF

docker compose up -d
sleep 5

curl -s -X POST http://localhost:8000/notify/passwords \
     -H "Content-Type: application/json" \
     -d "{\"monitoring_url\":\"${monitoring_url}\",\"elastic_pwd\":\"$${ELASTIC_PW}\",\"logstash_pwd\":\"$${LOGSTASH_PW}\",\"kibana_pwd\":\"$${KIBANA_PW}\"}"


echo "Init.sh complete."
