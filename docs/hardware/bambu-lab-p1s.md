# BambuLab P1S

I have a BambuLab P1S and given recently policy changes that mean I can't use Home Assistant or Orca Slicer without weird workarounds, I'm putting my printer in the IoT VLAN without access to the internet.

This utility: https://github.com/jonans/bsnotify/tree/main broadcasts the printer name from one VLAN to another, so the printer can stay in an isolated IoT VLAN and it can still appear in the Bambu app.

First I git cloned `bsnotify` into `/etc/bsnotify` .

Then I created this file in `/etc/systemd/system/bsnotify.service`:

```service
[Unit]
Description=BSNotify Service to enable Bambu Studio across VLANs

[Service]
Type=simple
ExecStart=python3 /etc/bsnotify/bsnotify <printerIp> <printerSerialNumber>

[Install]
WantedBy=multi-user.target
```

Then run 

```bash
systemctl daemon-reload
systemctl enable bsnotify.service
systemctl restart bsnotify.service 
systemctl status bsnotify.service
```

to set it up