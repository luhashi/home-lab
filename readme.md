# 🏠 Home Lab Setup Guide

This guide documents my personal home lab setup, following the exact installation order I used to set up my environment.

## 🖥️ Prerequisites

- A server or PC running Ubuntu with XFCE
- Internet connection
- Basic terminal knowledge

## 🔄 System Setup

### 1. Initial Ubuntu Setup

1. Install Ubuntu Server with XFCE desktop environment
2. Update and upgrade system packages:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. Install essential tools:
   ```bash
   sudo apt install -y git curl wget nano
   ```

### 2. Install Docker

1. Install required packages:
   ```bash
   sudo apt-get install -y \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   ```

2. Add Docker's official GPG key:
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

3. Set up the stable repository:
   ```bash
   echo \
     "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

4. Install Docker Engine:
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   ```

5. Add your user to the docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

6. Verify installation:
   ```bash
   docker --version
   docker run hello-world
   ```

## 🏠 Home Assistant Installation

1. Install required dependencies:
   ```bash
   sudo apt-get install -y \
       apparmor \
       jq \
       network-manager \
       socat \
       software-properties-common
   ```

2. Install OS Agent:
   ```bash
   wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_x86_64.deb
   sudo dpkg -i os-agent_1.6.0_linux_x86_64.deb
   ```

3. Install Home Assistant Supervisor:
   ```bash
   wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
   sudo dpkg -i homeassistant-supervised.deb
   ```

4. Access Home Assistant at: `http://your-server-ip:8123`

## 🤖 LittleLLM Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/BerriAI/littlellm
   cd littlellm
   ```

2. Create and edit the .env file:
   ```bash
   cp .env.example .env
   nano .env
   ```

3. Generate secure random strings and update:
   ```
   LITELLM_MASTER_KEY="sk-$(openssl rand -hex 16)"
   LITELLM_SALT_KEY="sk-$(openssl rand -hex 16)"
   ```

4. Start the services:
   ```bash
   sudo docker compose up -d
   ```

5. Access the dashboard at: `http://your-server-ip:3000`
   - Username: admin
   - Password: Your LITELLM_MASTER_KEY without the "sk-" prefix

## 🦙 Ollama Setup

1. Pull and run Ollama container:
   ```bash
   docker run -d \
     --name ollama \
     -p 11434:11434 \
     -v ollama:/root/.ollama \
     --restart always \
     ollama/ollama
   ```

2. Pull a model (example with llama2):
   ```bash
   docker exec ollama ollama pull llama2
   ```

3. Verify the installation:
   ```bash
   docker exec ollama ollama list
   ```

## 🌐 Open WebUI Setup

1. Run Open WebUI container:
   ```bash
   docker run -d \
     -p 3000:8080 \
     -v open-webui:/app/backend/data \
     -e OLLAMA_BASE_URL=http://your-server-ip:11434 \
     --name open-webui \
     --restart always \
     ghcr.io/open-webui/open-webui:main
   ```

2. Access Open WebUI at: `http://your-server-ip:3000`

## 🪞 Magic Mirror Setup (Optional)

1. Install dependencies:
   ```bash
   curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
   sudo apt install -y nodejs
   ```

2. Install MagicMirror:
   ```bash
   bash -c "$(curl -sL https://raw.githubusercontent.com/MichMich/MagicMirror/master/installers/raspberry.sh)"
   ```

3. Configure MagicMirror:
   ```bash
   cd ~/MagicMirror
   cp config/config.js.sample config/config.js
   nano config/config.js
   ```

4. Start MagicMirror:
   ```bash
   cd ~/MagicMirror
   npm run start
   ```

## 🔄 Maintenance

### Update All Services

```bash
# Update Docker containers
cd ~/littlellm
docker compose pull
docker compose up -d

docker pull ollama/ollama:latest
docker pull ghcr.io/open-webui/open-webui:main

# Restart all services
docker restart ollama open-webui
```

### Backup Configuration

```bash
# Create backup directory
mkdir -p ~/backups/$(date +%Y%m%d)

# Backup Docker volumes
docker run --rm -v ~/backups/$(date +%Y%m%d):/backup -v ollama:/source busybox tar czf /backup/ollama_backup_$(date +%Y%m%d).tar.gz -C /source .
docker run --rm -v ~/backups/$(date +%Y%m%d):/backup -v open-webui:/source busybox tar czf /backup/openwebui_backup_$(date +%Y%m%d).tar.gz -C /source .

# Backup Home Assistant configuration
sudo tar czf ~/backups/$(date +%Y%m%d)/homeassistant_backup_$(date +%Y%m%d).tar.gz /usr/share/hassio/homeassistant/
```

## 📝 Notes

- Replace `your-server-ip` with your actual server IP address
- Ensure ports 3000, 8123, and 11434 are open in your firewall
- For production use, consider setting up HTTPS with a reverse proxy like Nginx

## 🤝 Contributing

Feel free to submit issues and enhancement requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
