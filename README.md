# azure-scripts
Place to pull script for easy az cli spin-ups of SUSE Linux Enterprise and openSUSE images

Assumes end-user is logged in with a valid Microsoft subscription.

Set up environment and build VMs in a loop with this command:
curl -s https://raw.githubusercontent.com/susegrant/azure-scripts/main/az-env-setup.sh | bash

Build supplemental VMs in existing environment with this command:
curl -s https://raw.githubusercontent.com/susegrant/azure-scripts/main/build-vm.sh | bash

Allow SSH access to network security group with this command:
curl -s https://raw.githubusercontent.com/susegrant/azure-scripts/main/azure-allow-ssh-ip.sh | bash
