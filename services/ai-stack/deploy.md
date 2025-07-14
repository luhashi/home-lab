# AI Stack Deployment

This stack is dedicated to experimenting with local Large Language Models (LLMs) and related tools. It is defined in the `docker-compose.yml` file in this directory.

## Deployment Steps

This stack requires an `.env` file for API key management.

1.  **Create the Environment File**

    From within this directory (`services/ai-stack`), create a file named `.env` with the following content. Replace the placeholder values with secure, randomly generated keys.

    ```env
    # .env
    LITELLM_MASTER_KEY="sk-xxxxxxxxxxxxxxxx"
    LITELLM_SALT_KEY="sk-xxxxxxxxxxxxxxxx"
    ```
    > **Note:** This `.env` file is listed in the root `.gitignore` and should never be committed to your repository.

2.  **Run the Stack**

    With the `.env` file in place, run the following command to start all services in detached mode:
    ```bash
    docker-compose up -d
    ```

3.  **Accessing Services**
    *   **Open WebUI:** `http://<mercury-ip>:8080`
    *   **LiteLLM UI Dashboard:** `http://<mercury-ip>:3000`
    *   **Ollama API:** `http://<mercury-ip>:11434`
    *   **LiteLLM Proxy API:** `http://<mercury-ip>:4000`