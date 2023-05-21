#!/bin/bash

BLUEUTIL_URL="https://github.com/toy/blueutil/raw/master/blueutil"

# Check for blueutil install
if ! command -v blueutil &> /dev/null; then
	echo "Installing blueutil..."
	
	curl -LO "$BLUEUTIL_URL"
	chmod +x blueutil
	sudo mv blueutil /usr/local/bin/

	echo "blueutil installed"
else
	echo "blue already installed"
fi


# Create config file
touch $HOME/blueswitch-config.txt

connected_devices=$(blueutil --connected --format=json | jq -r '.[] | {name: .name, id: .address}')
# List devices
if [[ -z $connected_devices ]]; then
	echo "Please connect a device"
	exit 1
fi

while true; do
	echo "\n------------------------------\nConnected devices:\n------------------------------"
	i=1
	for device in $connected_devices; do
		name=$(echo "$device" | jq -r '.name')
		echo "$i. $name"
		((i++))
	done

	# Device selection
	read -p "\nEnter a number to select a device:" selection

	# Response validation
	if [[ $selection =~ ^[0-9]+$ && $selection -ge 1 && $selection -le $i ]]; then
		selected_device=$(echo "$connected_devices" | jq --argjson sel "$selection" '.[$sel-1].name')
		selected_device_id=$(echo "$connected_devices" | jq --argjson sel "$selection" '.[$sel-1].id')
		echo "Selected: $selected_device ($selected_device_id)"
	
		# Add selected device to config file
		sed -i "/^$/ s@^@$selected_device_id@" "$HOME/blueswitch-config.txt"
		echo "Device added to configuration"
	else
		echo "Invalid selection"
		exit 1;
	fi

	# Prompt next device
	read -p "\nDo you wish to add another device (y/n): " choice
	if [[ $choice == "n" ]]; then
		break
	fi
done
echo ***Configuration complete***
