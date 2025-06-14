#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to generate random string
generate_random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

# Function to install Docker
install_docker() {
    echo -e "${GREEN}Installing Docker...${NC}"
    
    # Install required packages
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable repository
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Add current user to docker group
    usermod -aG docker $SUDO_USER
    
    echo -e "${GREEN}Docker installed successfully!${NC}"
    echo -e "${YELLOW}Note: You may need to log out and back in for group changes to take effect.${NC}"
}

# Function to install Home Assistant
install_home_assistant() {
    echo -e "${GREEN}Installing Home Assistant...${NC}"
    
    # Install required dependencies
    apt-get install -y \
        apparmor \
        jq \
        network-manager \
        socat \
        software-properties-common

    # Install OS Agent
    wget https://github.com/home-assistant/os-agent/releases/download/1.6.0/os-agent_1.6.0_linux_x86_64.deb
    dpkg -i os-agent_1.6.0_linux_x86_64.deb
    rm os-agent_1.6.0_linux_x86_64.deb

    # Install Home Assistant Supervisor
    wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
    dpkg -i homeassistant-supervised.deb || true
    apt-get -f install -y
    rm homeassistant-supervised.deb
    
    echo -e "${GREEN}Home Assistant installed successfully!${NC}"
    echo -e "Access Home Assistant at: ${YELLOW}http://$(hostname -I | awk '{print $1}'):8123${NC}"
}

# Function to install LittleLLM
install_littlellm() {
    echo -e "${GREEN}Installing LittleLLM...${NC}"
    
    # Clone LittleLLM if not already cloned
    if [ ! -d "littlellm" ]; then
        git clone https://github.com/BerriAI/littlellm
    fi
    
    cd littlellm
    
    # Create .env if it doesn't exist
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}Creating .env file with random keys...${NC}"
        cp .env.example .env
        
        # Generate random keys
        MASTER_KEY="sk-$(generate_random_string)"
        SALT_KEY="sk-$(generate_random_string)"
        
        # Update .env file
        sed -i "s|LITELLM_MASTER_KEY=.*|LITELLM_MASTER_KEY=\"${MASTER_KEY}\"|" .env
        sed -i "s|LITELLM_SALT_KEY=.*|LITELLM_SALT_KEY=\"${SALT_KEY}\"|" .env
        
        echo -e "${GREEN}LittleLLM has been configured with the following credentials:${NC}"
        echo -e "Username: ${GREEN}admin${NC}"
        echo -e "Password: ${GREEN}${MASTER_KEY#sk-}${NC}"
        echo -e "\n${YELLOW}Please save these credentials in a secure place!${NC}"
    else
        echo -e "${YELLOW}.env file already exists. Using existing configuration.${NC}"
    fi
    
    # Start services
    echo -e "${GREEN}Starting LittleLLM services...${NC}"
    docker compose up -d
    
    echo -e "\n${GREEN}LittleLLM is now running!${NC}"
    echo -e "Dashboard: ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000${NC}"
    cd ..
}

# Function to install Ollama
install_ollama() {
    echo -e "${GREEN}Installing Ollama...${NC}"
    
    # Check if Ollama container exists
    if ! docker ps -a --format '{{.Names}}' | grep -q '^ollama$'; then
        echo -e "${GREEN}Creating Ollama container...${NC}"
        docker run -d \
          --name ollama \
          -p 11434:11434 \
          -v ollama:/root/.ollama \
          --restart always \
          ollama/ollama
        
        echo -e "${GREEN}Ollama container created. Pulling default model (llama2)...${NC}"
        docker exec ollama ollama pull llama2
    else
        echo -e "${YELLOW}Ollama container already exists. Starting if not running...${NC}"
        docker start ollama 2>/dev/null || true
    fi
    
    echo -e "\n${GREEN}Ollama is now running!${NC}"
    echo -e "Ollama API: ${YELLOW}http://$(hostname -I | awk '{print $1}'):11434${NC}"
}

# Function to install Open WebUI
install_openwebui() {
    echo -e "${GREEN}Installing Open WebUI...${NC}"
    
    # Check if Open WebUI container exists
    if ! docker ps -a --format '{{.Names}}' | grep -q '^open-webui$'; then
        echo -e "${GREEN}Creating Open WebUI container...${NC}"
        docker run -d \
          --name open-webui \
          -p 3000:8080 \
          -v open-webui:/app/backend/data \
          -e OLLAMA_BASE_URL=http://ollama:11434 \
          --restart always \
          --network home-lab \
          ghcr.io/open-webui/open-webui:main
    else
        echo -e "${YELLOW}Open WebUI container already exists. Starting if not running...${NC}"
        docker start open-webui 2>/dev/null || true
    fi
    
    echo -e "\n${GREEN}Open WebUI is now running!${NC}"
    echo -e "Access Open WebUI at: ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000${NC}"
}

# Main installation function
main() {
    echo -e "${GREEN}=== Home Lab Setup ===${NC}"
    echo -e "This script will install and configure the following services:"
    echo -e "1. Docker and Docker Compose"
    echo -e "2. Home Assistant"
    echo -e "3. LittleLLM (API key management)"
    echo -e "4. Ollama (Local LLM processing)"
    echo -e "5. Open WebUI (Web interface for Ollama)"
    echo ""
    
    read -p "Do you want to continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 1
    fi
    
    # Install Docker if not installed
    if ! command_exists docker; then
        install_docker
    else
        echo -e "${YELLOW}Docker is already installed.${NC}"
    fi
    
    # Install Home Assistant
    if ! systemctl is-active --quiet home-assistant@homeassistant; then
        install_home_assistant
    else
        echo -e "${YELLOW}Home Assistant is already installed.${NC}"
    fi
    
    # Create docker network if it doesn't exist
    if ! docker network ls | grep -q home-lab; then
        echo -e "${GREEN}Creating Docker network...${NC}"
        docker network create home-lab
    fi
    
    # Install LittleLLM
    install_littlellm
    
    # Install Ollama
    install_ollama
    
    # Install Open WebUI
    install_openwebui
    
    echo -e "\n${GREEN}=== Setup Complete! ===${NC}"
    echo -e "\nAccess your services:"
    echo -e "- Home Assistant: ${YELLOW}http://$(hostname -I | awk '{print $1}'):8123${NC}"
    echo -e "- LittleLLM Dashboard: ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000${NC}"
    echo -e "- Open WebUI: ${YELLOW}http://$(hostname -I | awk '{print $1}'):3000${NC}"
    echo -e "\n${YELLOW}Note:${NC} If you just installed Docker, you may need to log out and back in for group changes to take effect."
}

# Run the main function
main
