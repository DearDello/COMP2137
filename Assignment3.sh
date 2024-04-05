#!/bin/bash

# Function to update hostname
update_hostname() {
    local desired_name="$1"
    local current_name=$(hostname)

    if [[ "$desired_name" != "$current_name" ]]; then
        sudo hostnamectl set-hostname "$desired_name"
        echo "✅ Hostname updated to '$desired_name'."
    else
        echo "🔹 Hostname is already set to '$desired_name'."
    fi
}

# Function to update IP address
update_ip_address() {
    local desired_ip="$1"
    local current_ip=$(hostname -I | awk '{print $1}')

    if [[ "$desired_ip" != "$current_ip" ]]; then
        # Update netplan configuration (modify as needed)
        # Example: sudo sed -i "s/old_ip/$desired_ip/g" /etc/netplan/01-netcfg.yaml
        # Apply netplan changes
        sudo netplan apply
        echo "✅ IP address updated to '$desired_ip'."
    else
        echo "🔹 IP address is already set to '$desired_ip'."
    fi
}

# Function to update /etc/hosts entry
update_hosts_entry() {
    local desired_name="$1"
    local desired_ip="$2"

    if ! grep -q "$desired_ip\s*$desired_name" /etc/hosts; then
        echo "$desired_ip   $desired_name" | sudo tee -a /etc/hosts > /dev/null
        echo "✅ /etc/hosts entry updated for '$desired_name' with IP '$desired_ip'."
    else
        echo "🔹 Entry for '$desired_name' already exists in /etc/hosts."
    fi
}

# Main function
main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -verbose)
                verbose=true
                shift
                ;;
            -name)
                update_hostname "$2"
                shift 2
                ;;
            -ip)
                update_ip_address "$2"
                shift 2
                ;;
            -hostentry)
                update_hosts_entry "$2" "$3"
                shift 3
                ;;
            *)
                echo "Invalid option: $1"
                exit 1
                ;;
        esac
    done
}

# Execute main function
main "$@"
