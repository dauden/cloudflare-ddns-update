# CLOUDFLARE DDNS UPDATE

A Bash script to dynamically update DNS A-records for domains you own on cloudflare, useful for home or private servers running behind dynamic IP addresses.

---

## Use Case

You should use this script if:

- You own domains managed via cloudflare.
- You want to self-host services (such as on a Synology NAS or private server).
- Your hosting device is behind a router with a dynamic public IP (assigned by your ISP) and needs its domain DNS A-records kept up-to-date automatically.

**Example:**  
You own `your_name.com` and want to expose your NAS/server to the internet (e.g., access at `https://your_name.com`).  
This script ensures the DNS record on cloudflare always points to your current public IP.

> **Note:**  
> For subdomains (e.g., `blog.your_name.com` or `storage.your_name.com`), you can manage redirection easily with CNAME records pointing to a DynDNS domain.  
> However, the root domain (A-records) must be updated directly, as A-records cannot be CNAMES. This script targets the dynamic update of A-records.

---

## Develop / Script

### Get API key from Cloudflare
1. **Log in to Cloudflare**
   Go to [https://dash.cloudflare.com/login](https://dash.cloudflare.com/login) and log in.
2. **Go to My Profile**
   Click on your user icon (top right) → "My Profile".
3. **API Tokens / Keys**
   In the sidebar, select **API Tokens**.
4. **Global API Key**
    - Under "API Keys", find **Global API Key**.
    - Click "View" and enter your password to reveal the key.
    - **Copy** the key and store it securely. This is the value for your script’s . `API_KEY`

_Alternatively:_
- You can also generate a **custom token** (recommended for limiting permissions).
- Click "Create Token", follow the wizard (grant “Zone.DNS:Edit” for your zone).
- Copy and use the token.

### Get Zone Id from Cloudflare
1. **Go to the Cloudflare Dashboard**
   [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
2. **Select Your Domain / Site**
    - On the dashboard, click on the domain you wish to update.

3. **Find Zone ID**
    - At the bottom right of the **Overview** page, under the "API" section, you will see **Zone ID**.
    - **Copy** the Zone ID; use this in your script as the . `ZONE_ID`

> **Note:**
> 
> ⚠️ **Always keep your API Key safe and do not share it publicly.**

### Config Parameters

- The script expects a configuration file (`config.sh`) to be present in the same directory, defining necessary values such as:
    - `HOST`: Cloudflare API base URL.
    - `API_VERSION`: API version for Cloudflare DNS.
    - `ACCOUNT`: Your email from a Cloudflare account.
    - `LAST_IP_FILE`: File path to store the last known IP address.
    - `ZONE_ID`: The Zone ID of domain to update.
    - `API_KEY`: Your personal Cloudflare API key.
    - `RECORD_NAMES`: The DNS record's name (e.g., "@", "www", etc.).
- It uses `curl` for HTTP requests and `jq` for JSON parsing. Both utilities must be installed.

---

## Deploy the Script

### Synology NAS

1. Copy the `ddns.cloudflare.sh` script and `config.sh` to your Synology NAS.
2. Make sure both `curl` and `jq` are installed.
3. Set up a scheduled task in DSM to run the script periodically (e.g., every 10 minutes).

**Example:**
1. Create a directory for the script in the scripts shared folder: `/volume1/scripts/cloudflare_ddns/`
2. Copy the `ddns.cloudflare.sh` script and `config.sh` to this directory.
3. Make the script executable:
     ```bash
     chmod +x /volume1/scripts/cloudflare_ddns/ddns.cloudflare.sh
     ```
4. Install required dependencies:
  - For `curl`: It should be pre-installed on Synology.
  - For `jq`: Install via Package Center or manually:
    ```bash
    # Install Entware if not already installed
    sudo mkdir -p /opt
    sudo mount -o bind /volume1/@optware /opt
    wget -O - http://bin.entware.net/x64-k3.2/installer/generic.sh | /bin/sh
    # Install jq
    opkg update
    opkg install jq
    ```
5. Set up a scheduled task in DSM:
  - Open Control Panel → Task Scheduler
  - Click "Create" → "Scheduled Task" → "User-defined script"
  - Set a task name (e.g., "Cloudflare DDNS Update")
  - Set the user to "root"
  - Set the task to run as frequently as needed (recommended: every 10-15 minutes)
  - In the "Run command" field, enter:
    ```bash
    /volume1/scripts/cloudflare_ddns/ddns.cloudflare.sh
    ```
  - Click "OK" to save the task
### Local Server

1. Place the `ddns.cloudflare.sh` script and `config.sh` in your preferred directory.
2. Ensure `curl` and `jq` are available on your system.
3. Set up a cron job for periodic execution (e.g., via `crontab -e`).

---

This utility helps automate public IP tracking and DNS updating, keeping your self-hosted services reliably reachable over the internet.