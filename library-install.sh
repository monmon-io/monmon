#!/usr/bin/bash
echo ""
cd /var/www/html/BCM2835 && sudo ./configure && sudo make && sudo make check && sudo make install
echo ""
cd /var/www/html/WiringPi && ./build
echo ""
