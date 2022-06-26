#!/usr/bin/bash
clear
echo "=================
Installing monmon
=================

This install script uses Ansible to deploy monmon to your Raspberry Pi. This means
that Ansible needs to be installed on your LOCAL system (ie. the one you're on right
now), along with any dependencies.

If you do not want to install Ansible and its dependencies on your local system, you
should enter 'n' to cancel the installation."
echo ""
while true; do
    read -p "Do you want to continue? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit; break;;
        * ) echo ""; echo "Please answer y or n"; echo "";;
    esac
done
echo ""
echo ""
read -p "What is the IP address of your Raspberry Pi? (xxx.xxx.xxx.xxx): " ip_address
echo ""
echo ""
echo "NOTE: Both the GUI and CLI methods mentioned below are experimental"
echo ""
echo "monmon has a very minimal status page built-in, and in addition to having the 
Waveshare 1.3\" display flash when there's an issue with one of your Monit instances,
you can also (optionally) hookup an external HDMI display to the Pi and have it load
the monmon status page automatically at boot.

If you have no intention of hooking up an external HDMI display, then simply enter none
and ignore the rest of this text.

If you want to go with the GUI display method, type gui and the PIXEL desktop
environment will be installed and automatically loaded at boot, with the monmon Status
Page loading in the lightweight Midori web browser. Although this method is technically
possible, it's still pretty heavy for a Pi Zero 2 and below. Both the RAM and Swap
are going to be maxed or near maxed pretty much all the time.

If you want to go with the CLI display method, no actual GUI will be installed, and
instead the text-based Lynx web browser will load the monmon status page at boot."
echo ""
read -p "Enter the external HDMI display method (none/cli/gui): " startup_type_input
startup_type=${startup_type_input,,} # Lower-case the startup type input
if [[ $startup_type != 'cli' && $startup_type != 'gui' ]]
then
  startup_type=none
fi
echo ""
echo ""
echo "# Update repositories on local system"
echo ""
sudo apt update
echo ""
echo ""
echo "# Install Ansible and prerequisites on local system"
echo "# Packages: ansible, sshpass"
echo ""
sudo apt install ansible sshpass -y
echo ""
if [[ -f config ]]
then
  cp config ansible/config.custom.j2
fi
if [[ -f nodes ]]
then
  cp nodes ansible/nodes.custom.j2
fi
if [[ -f monit ]]
then
  cp monit ansible/monit.custom.j2
fi
if [[ -f include ]]
then
  cp include ansible/include.custom.j2
fi
echo ""
echo "# Run Ansible playbook to deploy monmon to Raspberry Pi"
cd ansible
sed -i "s/:::::RASPBERRY_PI_IP_ADDRESS:::::/$ip_address/g" inventory-install
sed -i "s/:::::RASPBERRY_PI_IP_ADDRESS:::::/$ip_address/g" roles/monmon/templates/nodes.j2
sed -i "s/:::::RASPBERRY_PI_MONITOR_STARTUP_TYPE:::::/$startup_type/g" group_vars/all.yml
ansible-playbook -i ./inventory-install ./install.yml
cd ..
echo ""
echo ""
echo "Installation complete!

The monmon status page should be available at http://$ip_address

The Monit web UI should be available at http://$ip_address:2812

In about 30 seconds, the screen attached to your Raspberry Pi should briefly turn green.
When this happens, it means that monmon is up-and-running.

If you installed one of the external HDMI display methods, and you see some red text
above, you may need to re-run the install.sh script. When installing one of these
methods, regardless of the Pi version, it sometimes takes so long that the password
escalation times out later on in the Ansible playbook, causing the playbook to fail. It
fails in a safe spot though, and re-running the install script (while entering the same
details as the last time you ran it) will simply pickup where it left off."
echo ""
