#!/bin/bash

# Check if a journal source name is provided
if [ $# -eq 0 ]; then
    echo "Please provide a journal source name"
    echo "Usage: $0 <journal_source_name>"
    exit 1
fi

# Journal source name from first argument
JOURNAL_SOURCE_NAME=$1

# Exit on any error
set -e

# Add Grafana apt repository
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

# Update package lists
apt-get update

# Install Grafana Alloy
apt-get install -y alloy

# Configure Alloy to listen on all interfaces
sed -i 's/^CUSTOM_ARGS=.*/CUSTOM_ARGS="--server.http.listen-addr=0.0.0.0:12345"/' /etc/default/alloy

# Create Alloy configuration with dynamic journal source name
cat > /etc/alloy/config.alloy << EOF
logging {
  level = "warn"
}

livedebugging {
  enabled = true
}

loki.source.journal "$JOURNAL_SOURCE_NAME" {
  forward_to = [loki.write.grafana_loki.receiver]
}

loki.write "grafana_loki" {
  endpoint {
    url = "http://192.168.86.226:3100/loki/api/v1/push"
  }
}
EOF

# Start and enable Alloy service
systemctl start alloy
systemctl enable alloy.service

echo "Grafana Alloy installation and configuration complete!"
echo "Journal source name set to: $JOURNAL_SOURCE_NAME"