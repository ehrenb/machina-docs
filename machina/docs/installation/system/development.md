# Development

## Clone

```bash linenums="1"
git clone --recurse-submodules https://github.com/ehrenb/machina.git &&\
    cd machina &&\
    git submodule foreach git checkout main &&\
    git submodule foreach git pull
```

## Build

Build in the proper order to ensure that parent base images are built first:

```bash linenums="1"
docker compose build base-alpine base-ubuntu &&\
    docker compose build base-ghidra &&\
    docker compose build
```

