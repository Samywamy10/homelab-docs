---
sidebar_position: 4
---

# ⬛ Frigate 

[Frigate](https://github.com/blakeblackshear/frigate) is one of the most interesting open source softwares I've seen, essentially a free NVR with a whole bunch of AI to support image recognition, all running locally. You can both input and output a range of cameras to a range of sources including [Home Assistant](./home-assistant.md), and review clip history in the web app.

## My setup
I use Frigate for two sources of cameras:
- A camera in my apartment for checking the cats while I'm out
- I'm the chairperson of the building committee, so its connected to the CCTV system in my apartment building

Frigate runs in Docker in a Docker LXC on `pve`, which also runs Home Assistant. I've passed through the Intel graphics device from the N100, which enables QuickSync and graphics transcoding, which significantly speeds up both video streaming as well as object/AI image detection.

I originally had an issue with Quicksync not working due to an issue with the Proxmox Linux Kernel. This has significant implications on performmance, with the ov Detector Inference Speed taking upwards of 100ms. I was able to fix it using the [steps here](https://github.com/tteck/Proxmox/discussions/.
2928#discussioncomment-9812253), which brings it down to approx 15ms.

I also record Frigate clips onto a cheap separate SSD in the mini PC. This enables both:
1. The actual Frigate instance/configuration is backed up separately without including the clips (so the backup is much smaller)
2. Clip recording and writing to the drive doesn't cause high iowait and therefore lag for everything else on the system (ie Home Assistant).

### Cat cam
The camera for the cats is a Reolink E1 Pro, a small PTZ camera. We keep the cats in the bathroom, so I've set the camera to physically rotate 180 degrees and point to the wall when the Aqara FP2 presence sensor detects a person in the bathroom.

Then in Frigate I'm tracking cat objects, so I can go into the UI and quickly jump to any object its detected as a cat. This means I can quickly see what the cats were up to the night before without needing to scrub through 8 hours of footage.

I also have this camera exposed to HomeKit so we can check it remotely.

### Apartment building cameras
I've set up a Tailscale link between Frigate and the OpenWRT router I installed in the communications cupboard of the building. This allows me to access the Dahua NVR the building's cameras connect to, as if it was a local device.

The Dahua NVR outputs rtsp streams, which I [restream](https://docs.frigate.video/configuration/restream/) so I can also connect to them in Home Assistant while only needing to connect to the NVR once per camera. I've had to use the secondary stream which is a lower quality as uploading the 6x cameras at a high resolution is too much for the 20mbps upload speed of the communications cupboard internet connection.

I've set up each camera in the carpark to detect both people and cars, while the other cameras in the common areas just detect people. This makes it easy to jump to notable events when incidents occur (mostly robberies) without scrubbing through footage of trees moving (or nothing at all).

I've set up zones to ignore movement outside of interest areas, and zones to ignore objects it commonly detects as people.


## Configuration
Configuration is saved [here](https://github.com/Samywamy10/frigate-config/blob/master/config.yml).


# Tips

To SSH into frigate, go to Promox and do: `docker exec -it frigate /bin/bash`