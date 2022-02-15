#!/bin/bash

echo -e "--------\nVM Setup\n--------"

read -p "Remind me, what's your Resource Group name again?: " group
read -p "Region?: " region
read -p "VNet?: " vnet
read -p "Subnet?: " subnet
read -p "NSG?: " nsg

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

read -p "Select size (Default is Standard_D1_v2): " size
if [ -z $size ]; then
	size="Standard_D1_v2"
fi

read -p "Image to use: (Default is urnAlias: suse:sles-15-sp3:gen1:latest): " image
if [ -z $image ]; then
	image="suse:sles-15-sp3:gen1:latest"
fi

az vm create --resource-group $group --name $vm_name --image $image --size $size --public-ip-sku Standard $ssh_config --vnet-name $vnet --subnet $subnet --nsg $nsg
