


# Build nzyme-tap in RPI 3B

Default Kali re4son linux libpcap does not provide a version built with libnl support which is required. Following the comment on https://github.com/nzymedefense/nzyme/discussions/339#discussioncomment-521229 build and install **libpcap with libnl support**.

>Once that is done, we want to pull in some things to make sure we can build packages.
>
>sudo apt install dpkg-dev build-essential -y
>
>Now we'll create a directory to download the sources and build the package in...
>
>mkdir -p source/libpcap/source - we do it this way because when you build packages, they're put into the directory UNDER your current one.
>
>cd source/libpcap/source
>
>apt source libpcap0.8
>
>cd libpcap-1.10.0
>
>`vim debian/control`
>
>Now we want to edit the debian/control file, and add a dependency to the **Build-Depends** line as well as the **Depends** of the libpcap0.8-dev Package. 
>Simply **add libnl-genl-3-dev**, to the list - I put it under the libdbus-1-dev, line (and the comma is very important so do not leave it out!) You can use your preferred editor, I just prefer vim.
>
>
>Now in the libpcap-1.10.0 directory we run an apt command to pull in the build dependencies:
>
>`sudo apt build-dep . `- again, the period is important - it's telling apt to install the dependencies that it finds in the debian/control file of the current directory; we want this and NOT libpcap0.8-dev because it does not have the added dependency.
>
>Once the dependencies are installed, simply run
>
>`dpkg-buildpackage -uc -us -b`
>
>Once that is done, you should be able to cd .. and you will have all of the libpcap deb files in that directory. We then install the libpcap deb that we need sudo dpkg -i libpcap0.8_1.10.0-2_$arch.deb 
>
>**NOTE**: you can use tab completion after the _ to complete the name if you do not know your architecture.
>
>Once that is done, we can test that it works with sudo tcpdump --monitor-mode -i wlan1
>
>

Install Rust employing the official distro. Download nyzme sources and cd into the `tap` folder of the project.

```
cargo build -r
```
# Disable monitor mode enabling

nzyme-tap will try to enable monitor mode in the configured interfaces. It will fail with stock RPI 3B wifi adapter. However, this can be omitted and was a feature available in previous nzyme versions <2.0 . To work around the issue we have to skip this functionality by removing the code in charge of doing it. This is between line 46 and 71 of tap/src/dot11/capture.rs (although through multiple versions might have a different position).

```rust 
// tap/src/dot11/capture.rs:46-71

        info!("Temporarily disabling interface [{}] ...", device_name);
        match nl.change_80211_interface_state(&device_name.to_string(), Down) {
            Ok(_) => info!("Device [{}] is now down.", device_name),
            Err(e) => {
                error!("Could not disable device [{}]: {}", device_name, e);
                return;
            }
        }

        info!("Enabling monitor mode on interface [{}] ...", device_name);
        match nl.enable_monitor_mode(&device_name.to_string()) {
            Ok(_) => info!("Device [{}] is now in monitor mode.", device_name),
            Err(e) => {
                error!("Could not set device [{}] to monitor mode: {}", device_name, e);
                return;
            }
        }

        info!("Enabling interface [{}] ...", device_name);
        match nl.change_80211_interface_state(&device_name.to_string(), Up) {
            Ok(_) => info!("Device [{}] is now up.", device_name),
            Err(e) => {
                error!("Could not enable device [{}]: {}", device_name, e);
                return;
            }
        }
```

# Hopper fails to switch channels

The monitor alias interface is not recognised by certain functions enumerating wifi interfaces in nzyme-tap. To workaround the issue disable channel hopper functionality with the followin configuration setting. 

```

[wifi_interfaces.mon0]
active = true
disable_hopper = true

```

The pitfall is that by disabling the hopper functionality the wifi adapter will stay listening to a single channel. But we can workaround the issue by externally modifying the channel the adapter is listening to using `iw`

```bash
#! /bin/bash

# Physical device, can be found with iw
PHY="phy0"
RADNOM=$$$(date +%s)
# Retrieve supported channels
channels=$(iw phy ${PHY} channels|grep "*"|awk '{print $4}'|sed -E 's/\[|\]//g')
while true; do
	channel=${channels[ $RANDOM % ${#channels[@]} ]}
	echo -e "\e[1A\e[KWifi channel change to $channel"
    # Change the adapters channel
	iw phy "$PHY" set channel "$channel"
    # Sleep some time to let nzyme-tap gather some data
	sleep 10;
done

```

# Routing eth0 to wifi locally 

```bash
sudo iptables -I FORWARD 1 -i eth0 -o wlp0s20f3 -j ACCEPT
sudo iptables -A FORWARD -i wlp0s20f3 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -I POSTROUTING 1 -s 192.168.1.0/24 -o wlp0s20f3 -j MASQUERADE
```