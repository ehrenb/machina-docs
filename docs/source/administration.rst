Administration
===================================

Management
-----------------------------------

Production
++++++++++

Section is WIP

Update
~~~~~~~~~~~~~

.. code-block:: bash

    cd machina
    docker compose pull

Development
++++++++++

Update (build)
~~~~~~~~~~~~~

.. code-block:: bash

    cd machina
    docker compose build base-alpine base-ubuntu && docker compose build

Start
++++++++++

.. code-block:: bash

    docker compose up -d

Scale
++++++++++


Scale worker modules to support parallel analyses

.. code-block:: bash

    docker compose up -d --scale identifier=2 androguardanalysis=5


Stop
++++++++++

.. code-block:: bash

    docker compose down

System stats
++++++++++


.. code-block:: bash

    docker stats $(docker compose ps | awk 'NR>2 {print $1}')

Services
-----------------------------------

* Neo4j GUI

    - http://127.0.0.1:7474
    - (default) username: neo4j
    - (default) password: tXOCq81bn7QfGTMJMrkQqP4J1

* RabbitMQ Management GUI

    - http://127.0.0.1:15672
    - (default) username: rabbitmq
    - (default) password: rabbitmq