#!/bin/bash

# Paths
SERVICE_FILE="/etc/systemd/system/macspoof@.service"
NM_CONF_FILE="/etc/NetworkManager/conf.d/wifi_rand_mac.conf"

# Function to add the configuration
add_configuration() {
    echo "Adding MAC address randomization and service configuration..."

    # Create the macspoof service file
    if [ ! -f "$SERVICE_FILE" ]; then
        sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=macchanger on %I
Wants=network-pre.target
Before=network-pre.target
BindsTo=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device

[Service]
ExecStart=/usr/bin/macchanger -e %I
Type=oneshot

[Install]
WantedBy=multi-user.target
EOL
        echo "Service file created: $SERVICE_FILE"
    else
        echo "Service file already exists: $SERVICE_FILE"
    fi

    # Create the NetworkManager configuration file
    if [ ! -f "$NM_CONF_FILE" ]; then
        sudo bash -c "cat > $NM_CONF_FILE" <<EOL
[device-mac-randomization]
wifi.scan-rand-mac-address=yes

[connection-mac-randomization]
ethernet.cloned-mac-address=random
wifi.cloned-mac-address=random
EOL
        echo "NetworkManager configuration file created: $NM_CONF_FILE"
    else
        echo "NetworkManager configuration file already exists: $NM_CONF_FILE"
    fi

    # Reload systemd and enable the service
    sudo systemctl daemon-reload
    sudo systemctl enable macspoof@\*
    echo "MAC spoofing service enabled."

    # Restart NetworkManager
    sudo systemctl restart NetworkManager
    echo "NetworkManager restarted with MAC randomization."
}


remove_configuration() {
    echo "Removing MAC address randomization and service configuration..."

    # Remove the macspoof service file
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm -f "$SERVICE_FILE"
        echo "Service file removed: $SERVICE_FILE"
    else
        echo "Service file does not exist: $SERVICE_FILE"
    fi

    # Remove the NetworkManager configuration file
    if [ -f "$NM_CONF_FILE" ]; then
        sudo rm -f "$NM_CONF_FILE"
        echo "NetworkManager configuration file removed: $NM_CONF_FILE"
    else
        echo "NetworkManager configuration file does not exist: $NM_CONF_FILE"
    fi

    # Reload systemd and disable the service
    sudo systemctl daemon-reload
    sudo systemctl disable macspoof@\*
    echo "MAC spoofing service disabled."

    # Restart NetworkManager
    sudo systemctl restart NetworkManager
    echo "NetworkManager restarted without MAC randomization."
}


if [[ $1 == "add" ]]; then
    add_configuration
elif [[ $1 == "remove" ]]; then
    remove_configuration
else
    echo "Usage: $0 {add|remove}"
    exit 1
fi