#!/bin/bash

read -p "Resource Group: " group
read -p "NSG name: " nsg

az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH" --priority 100 --access Allow --source-address-prefixes $(curl -s ifconfig.me)/32 --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from my public IP"
