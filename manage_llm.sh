#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Please run as root or with sudo${NC}"
    exit 1
fi

# Function to generate random string
generate_random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
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
    echo -e "Dashboard: http://$(hostname -I | awk '{print $1}'):3000"
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
    echo -e "Ollama API: http://$(hostname -I | awk '{print $1}'):11434"
    echo -e "To use with Open WebUI, set: OLLAMA_BASE_URL=http://$(hostname -I | awk '{print $1}'):11434"
}

# Function to show status
show_status() {
    echo -e "${GREEN}=== Service Status ===${NC}"
    
    # Check LittleLLM
    if [ -d "littlellm" ]; then
        cd littlellm
        echo -e "\n${YELLOW}LittleLLM Containers:${NC}"
        docker compose ps
        cd ..
    else
        echo -e "\n${YELLOW}LittleLLM is not installed.${NC}"
    fi
    
    # Check Ollama
    echo -e "\n${YELLOW}Ollama Container:${NC}"
    if docker ps -a --format '{{.Names}}' | grep -q '^ollama$'; then
        docker ps -a | grep ollama
        echo -e "\n${YELLOW}Installed Models:${NC}"
        docker exec ollama ollama list 2>/dev/null || echo "Ollama is not running"
    else
        echo "Ollama is not installed."
    fi
}

# Main menu
while true; do
    echo -e "\n${GREEN}=== LLM Management Menu ===${NC}"
    echo "1. Install/Update LittleLLM"
    echo "2. Install/Update Ollama"
    echo "3. Show Status"
    echo "4. Exit"
    echo -n "Choose an option (1-4): "
    
    read -r choice
    case $choice in
        1) install_littlellm ;;
        2) install_ollama ;;
        3) show_status ;;
        4) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
