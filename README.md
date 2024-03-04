# KarmaBody

A Web app to access the actuators and sensors of a Lego robot's body, real or simulated.

KarmaBody is responsible...

* For detecting the connected sensors and motors
* For providing, via HTTP, the list of sensors or motors, together with what they are* capable of and how to reach them
* For answering HTTP requests to sense and to act

## Getting started

Get yourself a Raspberry Pi3 and a [BrickPi3](https://www.dexterindustries.com/store/brickpi3-starter-kit/.)

You'll also need a [LEGO Mindstorms EV3 kit](https://www.lego.com/en-us/product/lego-mindstorms-ev3-31313). It is, sadly, a retired product, but you'll easily find a second-hand kit for sale in the usual places.

### Install Linux on the Raspberry Pi3 (RPI3)

The first step is to burn the EV3Dev ditribution of Linux on a micro SD Card.

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

You'll want the RPI3 to network via WiFi.

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
* On the PC, edit `/etc/hosts` to add a `brickpi3` alias for the ip address.

### Create a user `dev` on the RPI3 and login as `dev`

The EV3Dev distribution comes with a pre-defined user named `robot`. Though it is not required, create a new user named `dev` and assign a password.

* In the RPI3 SSH session, do
  * `sudo adduser dev`
  * `sudo usermod -aG sudo dev`

* Close the SSH session
* Unplug the Ethernet cable from the RPI3
* Put the PC on the same wifi network enabled on the RPI3
* Start a new SSH session on the RPI3 with `ssh dev@brickpi3`

### Reset the timezone

sudo dpkg-reconfigure tzdata

### Install Erlang and Elixir using `asdf`

KarmaBody is an Elixir web app. It requires Erlang (the runtime platform) and Elixir (the programming language) to be installed. 

The ASDF utility is used to do the installation.

* First, install ASDF

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

In an SSH session (`ssh dev@brickpi3`), clone the `karma_body` code repository on the RPI3.

``` bash
cd ~
git clone https://github.com/jfcloutier/karma_body.git
```

To update to the latest,

* Open an SSH session on `dev@brickpi3` and do

``` bash
cd ~/karma_body
git pull
```

### Connecting the BrickPi3 board

The BrickPi3 piggy-backs on the RPI3.

* Power off the RPI3
* Connect the BrickPi3 board to the RPI3
* Power on the RPI3 and open an SSH session to it via `ssh dev@brickpi3`
* Update its firmware if not running the latest by doing `sudo update-brickpi3-fw`
* Verify all is well with `ev3dev-sysinfo`

### Configuration

The BrickPi3 board needs to be told what kinds of devices are connected to its ports.

The information is provided in `~/karma_body/config.exs`. Edit the `brickpi3` section to reflect the actual configuration of sensors and motors.

For example:

``` elixir
config :karma_body,
  brickpi3: [
    [port: :in1, sensor: :touch]
    [port: :in2, sensor: :color],
    [port: :in3, sensor: :infrared],
    [port: :in4, sensor: :ultrasonic],
    # left
    [port: :outA, motor: :large_tacho],
    # right
    [port: :outB, motor: :large_tacho]
  ]
```

See `~/karma_body/lib/karma_body.ex` for the names of all supported devices, and `~/karma_body/lib/karma_body/platform/brickpi3.ex` for the list of all ports.

### Run KarmaBody

To run karma_body,

* Open an SSH session on `dev@brickpi3` and do

``` bash
cd ~/karma_body
iex -S mix phx.server
```

## REST API

Assuming the body is hosted at `http://192.168.50.242:4000`:

```bash
 $ wget -q -O - http://192.168.50.242:4000/api/sensors

{"sensors":[{"id":"touch_in1","type":"touch","url":"http://192.168.50.242:4000/api/sense/touch_in1/contact","capabilities":{"domain":["pressed","released"],"sense":"contact"}}]}

$ wget -q -O - http://192.168.50.242:4000/api/sense/touch_in1/contact

{"sensor":"touch_in1","sense":"contact","value":"released"}
```
