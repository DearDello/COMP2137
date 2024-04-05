#!/bin/bash

# Deploy configure-host.sh to servers and apply configurations
deploy_and_configure() {
    local script_path="./configure-host.sh"
    local remote_user="remoteadmin"
    local server1="server1-mgmt"
    local server2="server2-mgmt"

    # Transfer script to server1
    scp "$script_path" "$remote_user@$server1:/root"
    ssh "$remote_user@$server1" -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4

    # Transfer script to server2
    scp "$script_path" "$remote_user@$server2:/root"
    ssh "$remote_user@$server2" -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3

    # Update local machine
    ./configure-host.sh -hostentry loghost 192.168.16.3
    ./configure-host.sh -hostentry webhost 192.168.16.4
}

# Execute deployment
deploy_and_configure
