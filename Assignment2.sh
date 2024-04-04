#!/bin/bash

# Check if script is run with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to update netplan configuration
update_netplan() {
    local interface_name="ens33"  # Change this to your actual network interface name
    local new_ip_address="192.168.16.21/24"

    # Update netplan configuration
    cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface_name:
      addresses: [$new_ip_address]
      dhcp4: no
EOF

    # Apply the changes
    netplan apply
}

# Function to update /etc/hosts
update_hosts() {
    local hostname="server1"
    local new_ip="192.168.16.21"

    # Check if entry already exists
    if grep -q "$new_ip $hostname" /etc/hosts; then
        echo "Host entry already exists."
    else
        echo "$new_ip $hostname" >> /etc/hosts
        echo "Added $hostname to /etc/hosts."
    fi
}

# Function to install required software
install_software() {
    apt-get update
    apt-get install -y apache2 squid
}

# Function to configure firewall rules
configure_firewall() {
    ufw allow in on ens33 to any port 22 proto tcp  # Allow SSH on mgmt network
    ufw enable
}

# Main script execution
update_netplan
update_hosts
install_software
configure_firewall

echo "Assignment2 script executed successfully!"
