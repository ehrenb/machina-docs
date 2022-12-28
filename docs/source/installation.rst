Installation
===================================

This guide covers the system installation.  For CLI installation, see the "submission" section.

Production
-----------------------------------

Section is WIP

Update
++++++++++

.. code-block:: bash

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

.. code-block:: bash

    docker compose build base-alpine base-ubuntu && docker compose build