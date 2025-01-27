---
sidebar_position: 2
---

# 🖥️ Hardware

## Nodes

All nodes run an Intel N100 CPU, which is very low-powered; easy to purchase; and has Intel Quicksync for GPU tasks like Plex video encoding and Frigate ML object detection.

| Name | IP Address     | Device               | CPU        | RAM  | nvme SSD | SSD2   | Networking            | Use     | Purchased |
| ---- | -------------- | -------------------- | ---------- | ---- | -------- | ------ | --------------------- | ------- | --------- |
| pve  | 192.168.86.16  | Beelink Mini-S12 Pro | Intel N100 | 16gb | 512gb    | 1000gb | 1x 1gbps              | Primary | 30/04/24  |
| pve2 | 192.168.86.200 | TRIGKEY Green G5     | Intel N100 | 16gb | 512gb    | 2000gb | 2x 2.5gbps            | Backup  | 29/10/24  |
| nas  | 192.168.86.201 | MW-N100-NAS          | Intel N100 | 32gb | 1024gb   | 2000gb | 2x 2.5gbps, 1x 10gbps | NAS     | 26/12/24  |

![Beelink Mini-S12 Pro](./img/beelink-s12.JPG)
Beelink Mini-S12 Pro

![TRIGKEY Green G5](./img/green-g5.JPG)
TRIGKEY Green G5

![NAS](./img/nas.JPG)
NAS

## NAS
The NAS also has:
- 2x 16TB drive
- 1x 18TB drive

making up a raidz1 ZFS pool with 32TB effective storage. 

## Networking

| Type    | Model                  | Purpose            |
| ------- | ---------------------- | ------------------ |
| Router  | Unifi UCG Ultra        |                    |
| Switch  | Unifi Enterprise-8-POE | POE + 2.5gbps      |
| Switch  | Unifi Flex Mini        | Entertainment Unit |
| Wifi AP | Unifi U7 Pro           | Living Room        |
| Wifi AP | Unifi U6 Lite          | Basement           |

## TODO
- [ ] Raspberry Pi 4B?
- [ ] Cool idea: https://www.reddit.com/r/homeassistant/comments/1i9esrn/docking_tablet_remote/