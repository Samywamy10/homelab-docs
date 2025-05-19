---
sidebar_position: 1
---

# 🟨 Proxmox

Proxmox runs on each of the machines defined in [hardware](/hardware#nodes). I always run the [Proxmox VE Post Install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install) after setting up a new Node, to remove subscription nag and perform updates.

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

| App                                                     | Notes                                                                                                                       | Type |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ---- |
| [TrueNAS Scale](https://www.truenas.com/truenas-scale/) | Installed in a VM using TrueNAS ISO. Also runs Proxmox backup server as a VM which has direct access to the ZFS file system | VM   |
| Proxmox Backup Server - Backup                          | Disabled unless required. Used for restoring backups if TrueNAS isn't working                                               | VM   |

### Remote: `remote`
Running on a remote server using an i5-4570, 16gb RAM (soon to be 32gb) and 4x4TB mechanical HDDs.

| App                                                     | Notes                                                                                                                       | Type |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ---- |
| [TrueNAS Scale](https://www.truenas.com/truenas-scale/) | Installed in a VM using TrueNAS ISO. Also runs Proxmox backup server as a VM which has direct access to the ZFS file system | VM   |
| [Home Assistant](https://www.home-assistant.io/)        | [HAOS Proxmox install script](https://community-scripts.github.io/ProxmoxVE/scripts?id=haos-vm)                             | VM   |

## Proxmox Backups
My current backup strategy is nightly backups of each VM and LXC. I don't backup external drives (ie either data on either of the additional SSDs nor (obviously) any syncs to the NAS drives).

### Proxmox Backup Server

I have two active instances of Proxmox Backup Server (PBS), one locally and one remote. These are connected via [Sync Jobs](https://pbs.proxmox.com/docs/managing-remotes.html) each way (ie Local VMs & LXCs sync to Remote; Remote VMs & LXCs to Local).

PBS is great as it runs Garbage Collection (I have it configured to run at 5:00am every night) which removes any duplicate files. E.g. if you're backing up Home Assistant, it'll only keep the files in subsequent backups which it doesn't have saved in previous backups. This means if you have 1 backup that's 4gb and you backup a 2nd copy, it doesn't take up 8gb, it might take up 4.2gb. This ratio of data saving is known as the Deduplication factor and mine currently sits between 5 and 8 (so I can save 5-8 backups in the space that 1 would have otherwise taken up).

Each night at 4:00am, all VMs and LXCs backup to Proxmox Backup Server. Then, every hour, the sync job starts to sync with the remote PBS. This gives me two copies of each instance at any given time, which will be at most 23 hours 59 minutes out of date.

| PBS Name                  | Location | Instance             |
| ------------------------- | -------- | -------------------- |
| pbs                       | home     | remote (via truenas) |
| pbshome                   | remote   | nas (via truenas)    |
| pbs-backup (normally off) | home     | nas                  |

I run the main PBS servers as a Virtual Machine within the TrueNAS instance. This allows me to pass the backup directory directly through as a mount point to the PBS container instead of mounting an SMB file share, which [isn't recommended and has very slow performance.](https://forum.proxmox.com/threads/extremely-slow-pbs-speeds.102967/post-443436). Given TrueNAS and Proxmox Backup Server are on the same physical machine anyway, I don't see this as more or less risky.

#### Accessing PBS backups from the TrueNAS VM if TrueNAS or PBS is down

However, as I experienced, if I want to restore the TrueNAS VM itself, and TrueNAS is hosting the PBS VM, I can't restore from that PBS VM. I could restore from the remote PBS VM, but this is incredibly slow as I'm bottlenecked by Australia's (abysmal) internet upload speeds.

Proxmox Backup Server stores files in a way that essentially mandate restoration via a PBS instance - in that you can't just find the underlying files that PBS uses and restore them directly to Proxmox, you need to do it via PBS. So if your PBS instance is down, you need to spin up another instance of PBS to do the restoration. This can read any PBS instances' files if in the right directory. To do this:

1. Given TrueNAS Scale is down, we need to access the underlying storage. In my configuration these are just zfs pools. Assuming we have hardware access to the hard drives (ie the pcie SATA controller isn't passed through to the VM), we can do `zpool import <nameOfPool>` on the host Proxmox machine.
2. If the zpool is encrypted, you can unlock it via `zfs load-key <nameOfPool>` which asks you to paste in the HEX key from when you encrypted it
3. Now you can mount it via `zfs mount <nameOfPool>` which makes it available at `/<nameOfPool>`
4. From here you can browse the pool. I have PBS setup to use a ZVol called `ProxmoxBackupServerData` which was in one of my datasets.
5. ZVols ended up at `/dev/zvol/<NameOfPool>/**/<nameOfZVol>`, which I then did `parted -s <path>` on to get some further info (you may need to install `parted`). This told me the disk was at `/dev/z32p1`, so I guess the `p1` is the partition number. 
6. ChatGPT helped me on the output of the `parted` and then told me to mount the ZVol like so `mount /dev/zd32p1 /mnt/proxmox_backup`. From here I could explore the actual files PBS works with.
7. Spin up a new VM of Proxmox Backup Server, and create a new Directory and Datastore as you would normally. Take note of the path of the Directory that backs the Datastore. 
8. In the Shell in PBS, navigate to the Directory and remove all the files (e.g. `cd /mnt/datastore/<datastoreName>` and then `rm -rf *` (MAKE SURE YOU'RE IN THE RIGHT DIRECTORY)).
9. Still in the PBS Shell, use SCP to copy all files (including the hidden `.chunk` files) from your host Proxmox machine where you saved `/mnt/proxmox_backup`. For me, this looked like `scp -r root@<proxmoxHostIPAddress>:/mnt/proxmox_backup/* /mnt/datastore/<datastoreName>/`
10. Set up your Proxmox host to connect to the new PBS instance you've created by creating a new PBS storage connection. You will need to set up a new user for this and grant it relevant permissions to read/write the datastore.
11. Navigate to the actual VM or LXC you want to restore e.g. `cd /mnt/datastore/<datastoreName>/ns/<NameSpace>/vm/<VM_ID>`, edit the `owner` file and replace it with the user you just created.
12. You should now be able to see the backups to restore in either the storage entity in the node's instances list, or directly from the VM in the backup list after you select this new PBS instance as the storage.

## Past troubleshooting I might want to refer back to

### Mounting an SMB share (ie NAS)
**Update 19/01/25:** Apparently should be able to use this [Gist](https://gist.github.com/NorkzYT/14449b247dae9ac81ba4664564669299)

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

### LXC Start is failing with no logs

Looks something like

```
lxc_init: 845 Failed to run lxc.hook.pre-start for container "104"
__lxc_start: 2034 Failed to initialize container "104"
```

can run `pct start 104 --debug` to see logs

If issue is something like `can't read superblock on /dev/loop0`, do `pct fsck 104`. Then start again, should fix.

### VM or LXC is dying
Use `journalctl -xe` to see errors in host

### Expand zvol (for TrueNAS VM)
1. Expand the zvol size in TrueNAS
2. Restart TrueNAS
3. Go into the VM (PBS) and run `cfdisk /dev/<driveToExpand>`
4. Should see free space, select the partition to expand, select resize then confirm you want to expand to use free space.
5. Select `Write` to confirm changes
6. Then run `resize2fs /dev/<paritionToExpand>` -- NOTE SELECT PARTITION eg sdb1

### Can access internet but DNS not working (aka can't ping qualified domains like Google.com)
Issue with Tailscale. Haven't figured it out yet, might be because LXCs/VMs inherit Node DNS settings which are connected to Tailscale so they can access remote Proxmox Backup Server.

Anyway, can do `nano /etc/resolv.conf` and change `nameserver` to a public DNS server eg  `1.1.1.1` etc.

## Future projects
- [ ] Investigate node disk speeds. Do the nvme and SSD drives match with what I'd expect performance to be?
- [ ] Investigate whether IO delay/wait is actually related to disk speed in this case