# Administration

## Start

Start the system in the background:

```bash linenums="1"
docker compose up -d
```

## Scale

Scale up worker modules to support parallel analyses

```bash linenums="1"
docker compose up -d --scale identifier=2 androguardanalysis=5
```

## Stop

```bash linenums="1"
docker compose down
```

## System Stats

```bash linenums="1"
docker stats $(docker compose ps | awk 'NR>2 {print $1}')
```

## Services


* Neo4j GUI
    - http://127.0.0.1:7474
    - (default) username: neo4j
    - (default) password: tXOCq81bn7QfGTMJMrkQqP4J1

* RabbitMQ Management GUI
    - http://127.0.0.1:15672
    - (default) username: rabbitmq
    - (default) password: rabbitmq