# Core Infrastructure Deployment

These are the foundational, always-on services that manage the network and home automation. They are defined in the `docker-compose.yml` file in this directory.

## Deployment Steps

The `docker-compose.yml` for this stack uses local directories to persist configuration data.

1.  **Create Data Directories**

    From within this directory (`services/core-infra`), run the following command to create the necessary folders for persistent data:
    ```bash
    mkdir adguard_work adguard_conf homeassistant_config
    ```

2.  **Start the Services**
    Run the following command to start the containers in detached mode:
    ```bash
    docker-compose up -d
    ```

3.  **Access the Interfaces**
    *   **Home Assistant:** `http://<jupiter-ip>:8123`
    *   **AdGuard Home:** `http://<jupiter-ip>:8088` (Requires initial setup on first run).