# KarmaBody

A Web app to access the actuators and sensors of a Lego robot's body, real or simulated.

## Getting started

Get yourself a Raspberry Pi3 and a [BrickPi3](https://www.dexterindustries.com/store/brickpi3-starter-kit/.)

### Install Linux on the Raspberry Pi3 (RPI3)

* Follow isntructions in [ev3dev.org](https://www.ev3dev.org/downloads/) to download zipped EV3Dev on RPI image
* Unzip the zipped image
  * Use WindowInstaller (open app on image)
* Follow the [BrickPi3 instructions](https://docs.ev3dev.org/en/ev3dev-stretch/platforms/brickpi3.html) and in the `config.txt` file itself,  and edit `config.txt` on the SD Card
* Plug SD Card in the RPI3, connect to ethernet both a PC and the RPI3
* Power up the RPI3
* On the PC, open an SSH session on the RPI3 by doing `ssh robot@ev3dev.local`
  * The password is `maker`
* In the SSH session, do
  * `sudo apt edit-sources`, and add these to the apt sources

``` bash
deb http://archive.debian.org/debian stretch main contrib non-free
#deb-src http://archive.debian.org/debian stretch main contrib non-free

#deb-src http://archive.ev3dev.org/debian stretch main

```

* Then do
  * `sudo apt update`
  * `sudo apt-get install git curl build-essential autoconf`

### Enable WiFi on the RPI3

* Enable and setup WiFi as instructed [here](https://www.ev3dev.org/docs/tutorials/setting-up-wifi-using-the-command-line/)

```bash
connmanctl
connmanctl> enable wifi
connmanctl> scan wifi
connmanctl> services
connmanctl> agent on	
connmanctl> connect wifi_...
connmanctl> quit
```

* Get the RPI3's ip address on wlan0 by doing `ifconfig`
* On the PC, edit `/etc/hosts` to add a `brickpi3` alias for the ip address

### Create a user `dev` on the RPI3 and login as `dev`

* In the RPI3 SSH session, do
  * `sudo adduser dev`
  * `sudo usermod -aG sudo dev`

* Close the SSH session
* Unplug ethe Ethernet cable from the RPI3
* Put the PC on the same wifi network enabled on the RPI3
* Start a new SSH session on the RPI3 with `ssh dev@brickpi3`

### Reset the timezone

sudo dpkg-reconfigure tzdata

### Install Erlang and Elixir using `asdf`

* Install ASDF

``` bash
sudo apt install curl git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
```

* Add to `~/.bashrc`

``` BASH
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
```

* Install erlang with ASDF

``` bash
source .bashrc
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
sudo apt-get -y install libncurses5-dev
sudo apt-get -y install libssh-dev
asdf install erlang latest
asdf global erlang latest
```

* Install Elixir via asdf

``` bash
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf install elixir latest
```

* if asdf fails to install Elixir, do

``` BASH
cd ~
mkdir elixir
cd elixir
wget https://github.com/elixir-lang/elixir/releases/download/v1.16.1/elixir-otp-26.zip
unzip elixir-otp-26.zip
```

* Then, if not installing Elixir via asdf, add to .bashrc

``` bash
export PATH=$PATH:$HOME/elixir/bin
source ~/.bashrc
```

### Clone the Github repo

``` bash
cd ~
git clone https://github.com/jfcloutier/karma_body.git
```

### Connecting the BrickPi3 board

* Power off the RPI3
* Connect the BrickPi3 board to the RPI3
* Power on the RPI3 and open an SSH session to it via `ssh dev@brickpi3`
* Update its firmware if not running the latest by doing `sudo update-brickpi3-fw`
* Verify all is well with `ev3dev-sysinfo`

## REST API

Assuming the body is hosted at `http://192.168.50.242:4000`:

```bash
 $ wget -q -O - http://192.168.50.242:4000/api/sensors

{"sensors":[{"id":"touch_in1","type":"touch","url":"http://192.168.50.242:4000/api/sense/touch_in1/contact","capabilities":{"domain":["pressed","released"],"sense":"contact"}}]}

$ wget -q -O - http://192.168.50.242:4000/api/sense/touch_in1/contact

{"sensor":"touch_in1","sense":"contact","value":"released"}
```
