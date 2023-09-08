#!/bin/bash
# Add allowed SSH IPs to Network Security Group
# Author: Grant Marcroft

read -p "Resource Group: " group
read -p "NSG name: " nsg

read -p "Add IPv4, IPv6, both or allow SSH from open Internet? (4|6|b|Internet): " ipv

if [ $ipv == "4" ]; then
        az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH_v4" --priority 101 --access Allow --source-address-prefixes $(curl -s https://ipv4.icanhazip.com:443)/32 --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from my public IPv4 address"

elif [ $ipv == "6" ]; then
        az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH_v6" --priority 102 --access Allow --source-address-prefixes $(curl -s https://ipv6.icanhazip.com:443) --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from my IPv6 address"

elif [ $ipv == "b" ]; then
        az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH_v4" --priority 101 --access Allow --source-address-prefixes $(curl -s https://ipv4.icanhazip.com:443)/32 --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from my public IPv4 address"
        az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH_v6" --priority 102 --access Allow --source-address-prefixes $(curl -s https://ipv6.icanhazip.com:443) --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from my IPv6 address"

elif [ $ipv == "Internet" ]; then
        read -p "Are you sure you want to allow access from the open Internet? (y|n): " internet
                if [ $internet == "y" ]; then
                        az network nsg rule create --resource-group $group --nsg-name $nsg --name "Allow_SSH_Internet" --priority 103 --access Allow --source-address-prefixes Internet --destination-port-ranges 22 --protocol Tcp --description="Accept SSH connections from the open Internet"
                fi
else
        echo "Selection invalid.  Please try again.  Exiting."
fi;
