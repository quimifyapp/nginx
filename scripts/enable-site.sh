#!/bin/bash

# Define paths
SITES_AVAILABLE_DIR="../sites-available"
SITES_ENABLED_DIR="../sites-enabled"

# Check if the directories exist
if [ ! -d "$SITES_AVAILABLE_DIR" ]; then
    echo "Error: Nginx directories not found. Make sure Nginx is installed and configured."
    exit 1
fi

# List available sites
echo "Available sites:"
available_sites=($(ls "$SITES_AVAILABLE_DIR"))

# Check if there are any available sites
if [ ${#available_sites[@]} -eq 0 ]; then
    echo "No available sites found in $SITES_AVAILABLE_DIR."
    exit 1
fi

# Display available sites
for ((i=0; i<${#available_sites[@]}; i++)); do
    echo "$(($i+1)). ${available_sites[$i]}"
done

# Ask the user to pick a site
read -p "Enter the number of the site you want to enable: " site_number

# Validate user input
if ! [[ "$site_number" =~ ^[0-9]+$ ]] || [ "$site_number" -le 0 ] || [ "$site_number" -gt "${#available_sites[@]}" ]; then
    echo "Invalid input. Please enter a valid site number."
    exit 1
fi

selected_site="${available_sites[$(($site_number-1))]}"

# Ensure the sites-available directory exists
mkdir -p "$SITES_ENABLED_DIR"

# Create symlink in sites-enabled
if ln -s "$SITES_AVAILABLE_DIR/$selected_site" "$SITES_ENABLED_DIR/$selected_site"; then
    echo "Site '$selected_site' has been enabled."
    echo "Restart Nginx with 'nginx -s reload' for the changes to take effect."
else
    echo "Error: Unable to create symlink for '$selected_site'."
fi
