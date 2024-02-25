# Startnet Script for .NET Application with Nginx

This repository contains a Bash script (`startnet.sh`) designed to automate the setup process of a .NET application environment on an Ubuntu server. This includes installing the .NET SDK, runtime, ASP.NET Core runtime, and configuring Nginx as a reverse proxy to forward requests to the .NET application. This project is a fork of DotNetLinuxDeploy: https://github.com/mzand111/DotNetLinuxDeploy

## Prerequisites

- A server running Ubuntu.
- Sudo privileges on the server.

## How to Use

1. **Clone the Repository**

   First, clone this repository to your server:

   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

  ...or clone and move the startnet.sh script to your Ubuntu server:

2. **Make the Script Executable**

   Change the permission of the script to make it executable:

   ```bash
   chmod +x startnet.sh
   ```

3. **Run the Script**

   Execute the script by running:

   ```bash
   ./startnet.sh
   ```
    If you encounter the error: " /bin/bash^M: bad interpreter: No such file or directory". Run the script below:

   ```bash
      sudo apt install dos2unix
      dos2unix ./startnet.sh

   Follow the on-screen prompts to enter your applications name and your user name when requested. These inputs are crucial for setting up the environment correctly.

## What the Script Does

Here's a breakdown of the tasks performed by `startnet.sh`:

- Prompts you for your application's name and your user name.
- Installs the .NET SDK, runtime, and ASP.NET Core runtime using the Microsoft package signing key and package repository.
- Installs Nginx and configures it to forward requests to your .NET application.
- Sets up a directory for your application and configures the necessary permissions.
- Creates a systemd service file for your application, enabling and starting the service.
- Reloads Nginx to apply the configuration changes.

## Manual Steps

After running the script, you need to manually deploy your .NET application:

- Copy your application to `/var/www/app`.
- Run `sudo dotnet <YourAppName>.dll` inside `/var/www/app`.

## Final Notes

- The script is designed for use on Ubuntu and has been tested with Ubuntu 20.04 LTS.
- Ensure you have sudo privileges on your server to run the script successfully.
- Modify the script according to your specific needs or Ubuntu version if necessary.

For any issues or contributions, please open an issue or a pull request in this repository.

---