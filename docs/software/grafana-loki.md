---
sidebar_position: 7
---

# 🟨 Grafana Loki
This is a logging system using:
- Grafana: Visualisation
- Loki: Service to collect logs
- Alloy: Runs on clients to collect logs from

## Setting up Grafana + Loki 

Followed this guide: https://grafana.com/docs/loki/latest/setup/install/docker/#install-with-docker-on-linux



## Alloy

### Setting up Alloy on client

### ✨ Scripted ⭐

Run this on Debian-based systems:

```bash
wget -qO- https://lab.samjwright.com/alloy-install.sh | bash -s <insert_journal_name>
```

#### Manual

Basically follow the steps here: https://grafana.com/docs/alloy/latest/set-up/install/linux/

1. Run commands at the top of this file: https://apt.grafana.com/ to add Grafana apt repository
2. `apt-get update` to get new sources
3. `sudo systemctl start alloy && sudo systemctl enable alloy.service` to start and permanently run Alloy  
4. `nano /etc/default/alloy` to add `--server.http.listen-addr=0.0.0.0:12345` in the `CUSTOM_ARGS` environment variable to be able to access Alloy web UI on any machine
5. Follow guide to [Use Grafana Alloy to send logs](https://grafana.com/docs/alloy/latest/tutorials/send-logs-to-loki/).
   1. `nano /etc/alloy/config.alloy`
   2. Replace the file with the following code:

```hcl
logging {
  level = "warn"
}

livedebugging {
  enabled = true
}

loki.source.journal "pve2" {
  forward_to = [loki.write.grafana_loki.receiver]
}


loki.write "grafana_loki" {
  endpoint {
    url = "http://192.168.86.226:3100/loki/api/v1/push"
  }
}
```