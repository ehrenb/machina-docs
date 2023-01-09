Installation
===================================

This guide covers the system installation.  For CLI installation, see the "submission" section.

Pre-requisites
-----------------------------------

- `docker <https://docs.docker.com/engine/install/ubuntu/>`_ (including docker-compose-plugin)

Production
-----------------------------------

Clone
++++++++++

.. code-block:: bash

    git clone https://github.com/ehrenb/machina.git

Update
++++++++++

.. code-block:: bash

    cd machina/
    docker compose pull

Development
-----------------------------------

Clone
++++++++++

.. code-block:: bash

    git clone --recurse-submodules https://github.com/ehrenb/machina.git &&\
        cd machina &&\
        git submodule foreach git checkout main &&\
        git submodule foreach git pull

Build
++++++++++

The following command will ensure proper dependency build order

.. code-block:: bash

    docker compose build base-alpine base-ubuntu &&\
        docker compose build base-ghidra &&\
        docker compose build