---
sidebar_position: 1
---

# 🟨 Proxmox

Proxmox runs on each of the machines defined in [hardware](/docs/hardware#nodes). I always run the [Proxmox VE Post Install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install) after setting up a new Node, to remove subscription nag and perform updates.

Each of the nvme drives in each node is set up as a zfs drive as this is what [Proxmox High Availability requires](https://pve.proxmox.com/wiki/High_Availability) to use [storage replication](https://pve.proxmox.com/wiki/Storage_Replication) (in lieu of shared storage).

## Nodes

### Node 1: `pve`
This was the first Mini PC I bought, replacing a Raspberry Pi 4B+ as the Home Assistant host. With only a 1gbps Ethernet link, I've got it running less disk-intensive loads. This has a 1tb SSD for storing Frigate recordings & snapshots.

| App                                              | Notes                                                                                                | Type |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------- | ---- |
| [Home Assistant](https://www.home-assistant.io/) | [HAOS Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=haos-vm)      | VM   |
| Frigate and Recyclarr (via Docker LXC)           | [Docker LXC Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=docker) | LXC  |

### Node 2: `pve2`
Bought as a failover for `pve`, `pve2` has 2x 2.5gbps Ethernet links and is used for more network-intensive tasks like hosting Plex and doing Usenet downloads. This has a 2tb SSD passed through to the NZBGet LXC for downloading & unzipping Usenet files.

| App                                                                                                                    | Notes                                                                                                                                                                                                                                                                                                                                                                                              | Type |
| ---------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- |
| [CubeCoders AMP](https://cubecoders.com/AMP) (💰 $10 USD)                                                               | Running in a [Debian 12 LXC](https://community-scripts.github.io/ProxmoxVE/scripts?id=debian). A game server instance manager running a Project Zomboid game server (and could easily support a Minecraft server or other games). This needs a minimum of 4 cores and 8GB RAM or it won't start. It won't actually consume anywhere close to that even if there are users in your server.          | LXC  |
| [NZBGet](https://github.com/nzbgetcom/nzbget) (via [Docker image](https://hub.docker.com/r/linuxserver/nzbget) in LXC) | [Docker LXC Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=docker). Was originally using SABnzbd but it kept locking up and crashing the host machine. Actually think the problem here was Usenet file unzipping taking up 100% of IO and not letting anything else happen. I've since moved downloading to a separate SSD on this host and am having no issues. | LXC  |
| [Tautulli](https://tautulli.com/)                                                                                      | [Tautulli Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=tautulli). Provides stats & graphs about Plex                                                                                                                                                                                                                                                           | LXC  |
| [Plex](https://www.plex.tv/)                                                                                           | [Plex Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=plex). Streams media on the NAS to devices via a Netflix-like interface                                                                                                                                                                                                                                     | LXC  |
| [Sonarr](https://sonarr.tv/)                                                                                           | [Sonarr Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=sonarr)                                                                                                                                                                                                                                                                                                   | LXC  |
| [Overseerr](https://github.com/sct/overseerr)                                                                          | [Overseerr Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=overseerr). Syncs with Plex users' watch lists to trigger downloads automatically                                                                                                                                                                                                                      | LXC  |
| [Radarr](https://radarr.video/)                                                                                        | [Radarr Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=radarr)                                                                                                                                                                                                                                                                                                   | LXC  |
| [Prowlarr](https://prowlarr.com/)                                                                                      | [Prowlarr Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=prowlarr)                                                                                                                                                                                                                                                                                               | LXC  |

### Node 3: `nas`
Purchased as a replacement when I thought my QNAP TS-431KX's hard drive backplane was dying. Turns out it wasn't but was keen on moving to a more performant NAS (that supports modern 64-bit apps).

| App                                                     | Notes                               | Type |
| ------------------------------------------------------- | ----------------------------------- | ---- |
| [TrueNAS Scale](https://www.truenas.com/truenas-scale/) | Installed in a VM using TrueNAS ISO | VM   |

## Backups
My current backup strategy is nightly backups of each VM and LXC. I don't backup external drives (ie either data on either of the additional SSDs nor (obviously) any syncs to the NAS drives).

## Past troubleshooting I might want to refer back to

### Mounting an SMB share (ie NAS)
[This thread](https://forum.proxmox.com/threads/tutorial-unprivileged-lxcs-mount-cifs-shares.101795/) is the source of truth.

#### On the host (first time only)
1. Create the mount point:
```bash
mkdir -p /mnt/lxc_shares/nas_download`
```
2. Add NAS CIFS share to /etc/fstab.

!!! Adjust `//192.168.86.44/Download` in the middle of the command to match your CIFS hostname (or IP) //NAS/ and the share name /nas/. !!!
!!! Adjust user=USERNAME,pass=PASSWORD at the end of the command. !!!
Code:
```bash
{ echo '' ; echo '# Mount CIFS share on demand with rwx permissions for use in LXCs (manually added)' ; echo '//192.168.86.44/Download /mnt/lxc_shares/nas_download cifs _netdev,x-systemd.automount,noatime,noserverino,uid=100000,gid=110000,dir_mode=0770,file_mode=0770,user=USERNAME,pass=PASSWORD 0 0' ; } | tee -a /etc/fstab
```

3. Mount the share on the PVE host.
```bash
mount /mnt/lxc_shares/nas_rwx
```

#### On the LXC (for every new one)
1. Create the group `lxc_shares` with GID=10000 in the LXC which will match the GID=110000 on the PVE host.
```bash
groupadd -g 10000 lxc_shares
```
2. Add the `root` user to the group "lxc_shares".
```bash
usermod -aG lxc_shares root
```
3. Shutdown the LXC.

#### On the host (for every new LXC)
1. Add a bind mount of the share to the LXC config. **Make sure to update the LXC ID at the end of the command**
```bash
{ echo 'mp0: /mnt/lxc_shares/nas_download/,mp=/mnt/nas' ; } | tee -a /etc/pve/lxc/LXC_ChangeThisToCorrectID.conf
```

2. Start the LXC.

### IO Wait & Disk Speeds

Both Frigate recordings and Usenet downloading & extracting caused significant enough IO wait on Proxmox hosts to affect all other services on the machines to the point where they all became unresponsive. This was an annoying to debug and troubleshoot issue. I solved it in both cases by adding additional SSDs to both nodes and directing the high IO traffic workloads to these SSDs. This has fixed all issues relating to unresponsiveness but I'm a bit unsure on whether recording clips from Frigate or Usenet downloading & extracting should saturate the entire IO highway. I tried to run some disk speed tests on both the nvme drives and SSD of `pve` and it locked up the computer. I reset it and the zfs pool (the single nvme drive) corrupted and I had to reinstall Proxmox 🤔. Something to investigate

## Future projects
- [ ] Investigate node disk speeds. Do the nvme and SSD drives match with what I'd expect performance to be?
- [ ] Investigate whether IO delay/wait is actually related to disk speed in this case