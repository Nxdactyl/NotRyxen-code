#!/bin/bash

# Benar ASCII Art Banner
cat << "EOF"
888888ba             dP       888888ba                                      
88    `8b            88       88    `8b                                     
88     88 .d8888b. d8888P    a88aaaa8P' dP    dP dP.  .dP .d8888b. 88d888b. 
88     88 88'  `88   88       88   `8b. 88    88  `8bd8'  88ooood8 88'  `88 
88     88 88.  .88   88       88     88 88.  .88  .d88b.  88.  ... 88    88 
dP     dP `88888P'   dP       dP     dP `8888P88 dP'  `dP `88888P' dP    dP 
                                             .88                            
                                         d8888P                               
EOF

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale service

# Attempt auto-connect using placeholder key
sudo tailscale up 

echo "Tailscale setup attempted. Login."
