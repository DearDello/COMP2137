#!/bin/bash
# script for Assignment 2 in linux automation
# starting and following the procedure step by step for readabilty 
# firstly Function to check and modify network interface configuration

configure_network_interface() {
    echo "🌐 Configuring the network interface..."
    # Check if the desired IP address is already configured
    if ! grep -q "192.168.16.21" /etc/netplan/01-netcfg.yaml; then
        # Append the IP address configuration to the netplan file
        echo "    addresses:
      - 192.168.16.21/24" | sudo tee -a /etc/netplan/01-netcfg.yaml > /dev/null
        # Apply the netplan configuration
        sudo netplan apply
        echo "✅ Network interface configured successfully."
    else
        echo "🔹 Network interface is already configured."
    fi
}

# Function to update /etc/hosts file
update_hosts_file() {
    echo "📝 Updating the /etc/hosts file..."
    # Add an entry for server1 if it doesn't already exist
    if ! grep -q "192.168.16.21\s*server1" /etc/hosts; then
        echo "192.168.16.21   server1" | sudo tee -a /etc/hosts > /dev/null
        echo "✅ /etc/hosts file updated successfully."
    else
        echo "🔹 Entry for server1 already exists in /etc/hosts."
    fi
}

# Function to install and configure Apache2 web server
install_configure_apache2() {
    echo "🌐 Installing and configuring the Apache2 web server..."
    # Install Apache2 if it's not already installed
    if ! command -v apache2 &> /dev/null; then
        sudo apt update
        sudo apt install -y apache2
        echo "✅ Apache2 installed successfully."
    else
        echo "🔹 Apache2 is already installed."
    fi
    # Enable the Apache2 service
    sudo systemctl enable apache2
    sudo systemctl start apache2
    echo "✅ Apache2 service enabled and started."
}

# Function to install and configure Squid web proxy
install_configure_squid() {
    echo "🌐 Installing and configuring the Squid web proxy..."
    # Install Squid if it's not already installed
    if ! command -v squid &> /dev/null; then
        sudo apt update
        sudo apt install -y squid
        echo "✅ Squid installed successfully."
    else
        echo "🔹 Squid is already installed."
    fi
    # Enable the Squid service
    sudo systemctl enable squid
    sudo systemctl start squid
    echo "✅ Squid service enabled and started."
}

# Function to configure UFW firewall rules
configure_ufw_firewall() {
    echo "🔥 Configuring the UFW firewall..."
    # Allow SSH on the management network (assuming the interface name is eth0)
    sudo ufw allow in on eth0 to any port 22
    # Allow HTTP on all interfaces
    sudo ufw allow http
    # Allow the Squid proxy port (assuming the default port is 3128) on all interfaces
    sudo ufw allow 3128
    # Enable the UFW firewall
    sudo ufw --force enable
    echo "✅ UFW firewall configured successfully."
}

# Function to create user accounts and configure SSH keys
create_user_accounts() {
    echo "👥 Creating user accounts and configuring SSH keys..."
    # Define user accounts and their SSH keys
    users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
    for user in "${users[@]}"; do
        # Create the user if it doesn't already exist
        if ! id "$user" &>/dev/null; then
            sudo adduser --disabled-password --gecos "" "$user"
        fi
        # Configure the home directory and default shell
        sudo usermod --shell /bin/bash "$user"
        # Ensure the user has a .ssh directory with an authorized_keys file
        sudo mkdir -p "/home/$user/.ssh"
        sudo touch "/home/$user/.ssh/authorized_keys"
        sudo chmod 700 "/home/$user/.ssh"
        sudo chmod 600 "/home/$user/.ssh/authorized_keys"
            # Add SSH public keys for rsa and ed25519 algorithms
        sudo bash -c "cat << EOF >> /home/$user/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm
# Add rsa public key here
EOF"
        echo "✅ User account '$user' created and SSH keys configured."
    done
    # Grant sudo access to 'dennis' user
    sudo usermod -aG sudo dennis
    echo "✅ Sudo access granted to user 'dennis'."
}

# Main function to execute configuration tasks
main() {
    configure_network_interface
    update_hosts_file
    install_configure_apache2
    install_configure_squid
    configure_ufw_firewall
    create_user_accounts
    echo "🎉 Assignment 2 script execution completed successfully! 🎉"
}
