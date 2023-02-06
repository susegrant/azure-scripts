#!/bin/bash
# Create one or more Azure VMs with all needed dependencies
# Author: Grant Marcroft

# Tag with service request number
tag=""

read -p "Does this involve an active Microsoft Support Request? (y|n): " srbool

if [ $srbool == 'y' ]; then
        
        read -p "SUSE Service Request #: " srtag

        tag=" --tags ServiceRequest=$srtag"
fi

# Create Resource Group
function rg_create() { 
        echo -e "--------------------\nResource Group Setup\n--------------------"
        read -p "Location (region) list? (y|n): " rl
        if [ $rl == "y" ]; then
                az account list-locations --output table;
        fi
        read -p "Please enter your region: " region
        read -p "Resource Group name: " group
        az group create --resource-group $group --location $region $tag
};

# Set up Network
function network_create() {
        echo -e "-------------\nNetwork Setup\n-------------"
        read -p "VNet name: " vnet
        read -p "Subnet name: " subnet 
        read -p "Network Security Group name: " nsg
        az network nsg create --resource-group $group --name $nsg $tag
        read -p "Add your public IP to allowed SSH client IPs in NSG? (y|n): " allow_ssh
        if [ $allow_ssh == "y" ]; then
                az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH" --priority 100 --access Allow --source-address-prefixes $(curl -s ifconfig.me)/32 --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from my public IP"
        fi 
        az network vnet create --resource-group $group --name $vnet --address-prefix 10.0.0.0/16 --subnet-name $subnet --subnet-prefix 10.0.0.0/24 --network-security-group $nsg $tag
};

# Build VM
function vm_create() {
        echo -e "--------\nVM Setup\n--------"
        read -p "List VM sizes? (y|n): " list_sizes
        if [ $list_sizes == "y" ]; then
                az vm list-sizes --location $region | grep "name" | cut --delimiter='"' --fields=4 | sort
        fi
        read -p "List SUSE images? (y|n): " list_images
        if [ $list_images == "y" ]; then
                az vm image list --publisher suse --all | grep "urn" | cut --delimiter='"' --fields=4 | sort --reverse --key=4 --field-separator=':'
        fi
        read -p "Name your VM: " vm_name
        read -p "Existing SSH key pair? (y|n): " key_exists
        if [ $key_exists == "y" ]; then
                read -p "Path to public key: " pub_key
                ssh_config="--ssh-key-value $pub_key"
                else
                ssh_config="--generate-ssh-keys"
        fi
        read -p "Select size (Default is Standard_DS1_v2): " size
        if [ -z $size ]; then
                size="Standard_DS1_v2"
        fi
        read -p "Image to use (Default is suse:sles-15-sp3:gen1:latest): " image
        if [ -z $image ]; then
                image="suse:sles-15-sp3:gen1:latest"
        fi
        az vm create --resource-group $group --name $vm_name --image $image --size $size --public-ip-sku Standard $ssh_config --vnet-name $vnet --subnet $subnet --nsg $nsg $tag

        read -p "Auto-Shutdown Enabled? (y|n):" autoshutdown
        if [ $autoshutdown != "n" ]; then
                read -p "Time in UTC for auto-shutdown (format hhmm): " time
                az vm auto-shutdown --resource-group $group --name $vm_name --time $time
        fi
};

# Call main
function main() {
        rg_create;
        network_create;
        read -p "Build new VM now? (y|n): " vmbool
        while [ $vmbool == "y" ]; do
                vm_create
                read -p "Build another VM? (y|n): " vmbool
        done;
};

main;
