# Production

## Clone

```bash linenums="1"
git clone https://github.com/ehrenb/machina.git
```

## Update/Pull

```bash linenums="1"
cd machina && \
    docker compose pull
```

!!! note

    By default the 'latest' stable image versions will be used to pull.  To change to a specific version, modify the 'latest' tag in the docker-compose.yml file cloned