#!/bin/bash
# Add VMs to existing RG and Network
# Author: Grant Marcroft
 
# Tag with service request number
tag=""

read -p "Does this involve an active Microsoft Support Request? (y|n): " srbool

if [ $srbool == 'y' ]; then
        
        read -p "SUSE Service Request #: " srtag

        tag=" --tags ServiceRequest=$srtag"
fi

echo -e "--------\nVM Setup\n--------"

read -p "Remind me, what's your Resource Group name again?: " group
read -p "Region?: " region
read -p "VNet name?: " vnet
read -p "Subnet name?: " subnet
read -p "NSG name?: " nsg

read -p "List Sizes? (y|n): " list_sizes
if [ $list_sizes == "y" ]; then
        sizes=$(az vm list-sizes --location $region | grep "name" | cut -d'"' -f 4 | sort )
        echo "$sizes"
fi

read -p "List SUSE Images? (y|n): " list_images
if [ $list_images == "y" ]; then
        images=$(az vm image list --publisher suse --all | grep urn | cut -d'"' -f4 | sort -r -k 4 -t':')
        echo "$images";
fi

read -p "Name your VM: " vm_name

read -p "Existing SSH Key Pair? (y|n): " key_exists
if [ $key_exists == "y" ]; then
        read -p "Path To Public Key: " pub_key
        ssh_config="--ssh-key-value $pub_key"
else
        ssh_config="--generate-ssh-keys"
fi

read -p "Select size (Default is Standard_DS1_v2): " size

if [ -z $size ]; then size="Standard_DS1_v2"; fi

read -p "Image to use: (Default is urnAlias: suse:sles-15-sp4:gen2:latest): " image

if [ -z $image ]; then image="suse:sles-15-sp4:gen2:latest"; fi

az vm create --resource-group $group --name $vm_name --image $image --size $size --public-ip-sku Standard $ssh_config --vnet-name $vnet --subnet $subnet --nsg $nsg $tag

# Auto-shutdown
read -p "Auto-Shutdown Enabled? defaults to yes (y|n): " autoshutdown
if [ -z $autoshutdown ]; then autoshutdown="y"; fi
if [ "$autoshutdown" != "n" ]; then
        read -p "Time in UTC for auto-shutdown (format hhmm, default 0000): " time
        if [ -z $time ]; then time="0000"; fi
        az vm auto-shutdown --resource-group $group --name $vm_name --time $time
fi
