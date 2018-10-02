#!/usr/bin/env bash
set -euox pipefail

# Debian apt-get install function to eliminate prompts
export DEBIAN_FRONTEND=noninteractive
apt_get_install()
{
 DEBIAN_FRONTEND=noninteractive apt-get -y \
 -o DPkg::Options::=--force-confnew \
 install $@
}

# Update the packace indexes
apt-get update
apt_get_install ntp
apt_get_install ntpdate

# Configure NTP
service ntp stop # Stop ntp daemon to free NTP socket
sleep 3 # Give the daemon some time to exit
ntpdate pool.ntp.org # Sync time
service ntp start # Re-enable the NTP daemon

# Configure other system-specific settings ... 
 
# Configure automatic security updates
cat > /etc/apt/apt.conf.d/20auto-upgrades << "EOF"
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
/etc/init.d/unattended-upgrades restart
 
# Update system limits
cat > /etc/security/limits.d/my_limits.conf << "EOF"
*               soft    nofile          999999
*               hard    nofile          999999
root            soft    nofile          999999
root            hard    nofile          999999
EOF
ulimit -n 999999

apt_get_install docker docker-compose

usermod -aG docker ubuntu

[[ -e /home/ubuntu/prediction-io ]] || git clone https://github.com/spring-media/rbbt-prediction-io.git /home/ubuntu/prediction-io
docker build -t pio /home/ubuntu/prediction-io/pio/
docker-compose --file /home/ubuntu/prediction-io/docker-compose.prod.yml up
