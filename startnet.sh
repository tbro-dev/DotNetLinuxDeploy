#!/bin/bash

echo -e "=============================================================="
read -p "Enter your applications name: " YOUR_APP_NAME
echo -e "=============================================================="
read -p "Enter your user name: " YOUR_USER_NAME
echo -e "=============================================================="
echo -e "=============================================================="
read -p "Enter the dotnet version to install (e.g., 6.0): " DOTNET_VERSION
echo -e "=============================================================="

# Define your application's name and username variables for easy replacement
#YOUR_APP_NAME="YourActualAppName" # Replace YourActualAppName with your app's name
#YOUR_USER_NAME="YourActualUserName" # Replace YourActualUserName with your username

# Exit script on error
set -e

#Installing with APT can be done with a few commands. Before you install .NET, run the following commands to add the Microsoft package signing key to your list of trusted keys and add the package repository.

# Get Ubuntu version
declare REPO_VERSION=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

# Download Microsoft signing key and repository
wget https://packages.microsoft.com/config/ubuntu/$REPO_VERSION/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install Microsoft signing key and repository
sudo dpkg -i packages-microsoft-prod.deb

# Clean up
rm packages-microsoft-prod.deb

# Update package lists
sudo apt-get update

# Install .NET SDK, runtime, and ASP.NET Core runtime
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh

chmod +x ./dotnet-install.sh

./dotnet-install.sh --version ${DOTNET_VERSION}

# Check .NET installation
dotnet --info

# Install Nginx
sudo apt install -y nginx

# Configure Nginx to forward requests to your .NET app
NGINX_CONF="/etc/nginx/sites-available/default"
sudo cp $NGINX_CONF "${NGINX_CONF}.bak" # Backup original configuration
sudo sed -i '/server {/,$d' $NGINX_CONF

echo 'server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;
        location / {
            proxy_pass http://localhost:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection keep-alive;
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }' | sudo tee -a $NGINX_CONF

# Create and set permissions for the app directory
sudo mkdir -p /var/www/app
sudo chmod 755 /var/www/app
sudo chown "$YOUR_USER_NAME" /var/www/app # Use the variable for username

# Reminder to manually deploy the app
echo "Please manually copy ${YOUR_APP_NAME} to /var/www/app and then run 'sudo dotnet ${YOUR_APP_NAME}.dll' inside."

# Create a systemd service file for the app
SERVICE_FILE="/etc/systemd/system/${YOUR_APP_NAME}.service"
echo "[Unit]
Description=.NET Web Application

[Service]
WorkingDirectory=/var/www/app
ExecStart=/usr/bin/dotnet /var/www/app/${YOUR_APP_NAME}.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-example
User=$YOUR_USER_NAME
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE

# Enable and start the service
sudo systemctl enable "${YOUR_APP_NAME}.service"
sudo systemctl start "${YOUR_APP_NAME}.service"

# Reload Nginx to apply changes
sudo nginx -s reload

# Final reminder message
echo "Setup completed."
