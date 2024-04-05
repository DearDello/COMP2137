#!/bin/bash


log_changes() {
    if [ "$verbose" == "true" ]; then
        echo "$1"
    fi
}


while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -verbose)
            verbose="true"
            shift
            ;;
        -name)
            desiredName="$2"
            shift
            shift
            ;;
        -ip)
            desiredIPAddress="$2"
            shift
            shift
            ;;
        -hostentry)
            desiredHost="$2"
            desiredHostIP="$3"
            shift
            shift
            shift
            ;;
        *)
            shift
            ;;
    esac
done


if [ -n "$desiredName" ]; then
    currentName=$(hostname)
    if [ "$currentName" != "$desiredName" ]; then
        log_changes "Changing hostname to $desiredName"
        echo "$desiredName" | sudo tee /etc/hostname >/dev/null
        sudo hostnamectl set-hostname "$desiredName" >/dev/null
        logger "Changed hostname to $desiredName"
    fi
fi


if [ -n "$desiredIPAddress" ]; then
    currentIP=$(hostname -I | awk '{print $1}')
    if [ "$currentIP" != "$desiredIPAddress" ]; then
        log_changes "Changing IP address to $desiredIPAddress"
        sudo sed -i "/$(hostname)/d" /etc/hosts >/dev/null
        echo "$desiredIPAddress $(hostname)" | sudo tee -a /etc/hosts >/dev/null
        sudo netplan apply >/dev/null
        logger "Changed IP address to $desiredIPAddress"
    fi
fi

if [ -n "$desiredHost" ] && [ -n "$desiredHostIP" ]; then
    if ! grep -q "$desiredHost" /etc/hosts || ! grep -q "$desiredHostIP" /etc/hosts; then
        log_changes "Adding host entry: $desiredHost $desiredHostIP"
        echo "$desiredHostIP $desiredHost" | sudo tee -a /etc/hosts >/dev/null
        logger "Added host entry: $desiredHost $desiredHostIP"
    fi
fi

exit 0
