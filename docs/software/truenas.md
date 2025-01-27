---
sidebar_position: 6
---

# 🟦 TrueNAS Scale

I run an instance of TrueNAS Scale both locally and remotely, both for local network file sharing at both locations, as well as providing a remote backup target.

## Pools
The NAS has two ZFS pools.

### Tennis
In raidz1:
- 3x 16TB drive
- 1x 18TB drive (conforms to 16TB as the minimum size in the pool)

Brings up approx 48TB of usable storage.

### Basketball
The "fast" pool in a mirror:
- 2x 2tb SSDs

This is replicated via snapshots hourly to a backup location on Tennis given the lack of built in redundancy.

## Backups
I have a Dataset within Tennis called "Important" which is backed up via snapshot replication every hour to the remote Dataset "ImportantRemote". This is in addition to Basketball replication to Tennis every hour.

### Creating a new replication job

To set up a dataset replication job with encrypted datasets, choose the source dataset in the replication job, then in the destination, choose the folder in the picker, and then add your own name for a new dataset it'll create e.g. `/Tennis/<enterYourNameHere>`. See this [reddit post](https://www.reddit.com/r/truenas/comments/12jt74p/how_to_replicate_encrypted_dataset/)