Periodic Worker Development
===================================

This type of Machina worker triggers an analysis periodically.  This is useful for longer-running analysis work that isn't feasible to be run on-demand for every new ingested sample.  
One Periodic Worker example is SimilarityAnalysis.  SimilartyAnalysis runs every hour, over all data in the graph, and updates/creates similarity relationships.


Dockerfile
-----------------------------------

Install any system dependencies required within your worker's Dockerfile.  There are two base image options provided:

Base image options:

- `behren/machina-base-alpine <https://hub.docker.com/repository/docker/behren/machina-base-alpine>`_  
- `behren/machina-base-ubuntu <https://hub.docker.com/repository/docker/behren/machina-base-ubuntu>`_

Dockerfile example:

.. code-block:: dockerfile
    :caption: example dockerfile

    FROM behren/machina-base-ubuntu:latest
    ...
    RUN apt update && apt install libz-dev
    ...


requirements.txt
-----------------------------------

Put any Python 3 requirements required by your worker module into requirements.txt 
and ensure that you copy requirements.txt into the image and 'pip3 install -r requirements.txt' to install the dependencies

youranalysismodule.py
-----------------------------------

This file contains the implementation of your worker module. Subclass the machina.core.periodic_worker.PeriodicWorker class, this will ensure your worker module has boilerplate connectivity to the database, and configurations.
The 'callback' function fires at the interval your analysis module is configured to.

.. code-block:: python3
    :caption: youranalysismodule.py handles zip data

    class YourAnalysisModule(PeriodicWorker):

        def __init__(self, *args, **kwargs):
            super(YourAnalysisModule, self).__init__(*args, **kwargs)
            ...

        def callback(self):
            self.logger.info("I'm firing!")


The PeriodicWorker provides some common triggers that can be used to further constrain execution at the configured interval.  For example, 'n_nodes_added_since' 
can be used to fire an analysis only if 1,000 new nodes of class type 'Elf' have been added within the last 1 hour.  These available triggers are documented within the machina core API.


.. code-block:: python3
    :caption: youranalysismodule.py handles zip data

    from datetime import timedelta
    from machina.core.models import Elf

    class YourAnalysisModule(PeriodicWorker):

        def __init__(self, *args, **kwargs):
            super(YourAnalysisModule, self).__init__(*args, **kwargs)
            ...

        def callback(self):
            if self.n_nodes_added_since(
                1000,
                Elf,
                timedelta(seconds=60)
            ):
                self.logger.info("I'm firing under a special constraint!")

YourAnalysisModule.json (configuration)
-----------------------------------

This top-level configuration file belongs in machina/configs/workers/youranalysismodule.json.  This file allows for reconfiguration without rebuilding of images or code.  This file
must be named after the worker class name that it corresponds to.  Configuration data set in this file is made available through the worker module's 'self.config["worker"] attribute.
Log level is handled by the PeriodicWorker base class to automatically adjust the subclass logging level if it is overridden in the configuration.  The interval for invoking 'callback' is 
also handled by the PeriodicWorker base class, and can be overridden in the configuration.

In the below example, 'log_level' and 'interval' are overridden and replace the default base configurations ('INFO' and 'hourly').


.. code-block:: json
    :caption: YourAnalysisModule.json

    {
        "log_level": "debug",
        "interval": "minutely",
        "new_value": "I'm a new configuration!"
            
    }

.. note::
    Complex intervals can be set up.  Under the hood, the PeriodicWorker uses `rocketry <https://rocketry.readthedocs.io/>`_ for scheduling.  Rocketry provides a verbose syntax for describing
    intervals, outlined `here <https://rocketry.readthedocs.io/en/stable/condition_syntax/execution.html?highlight=hourly#execution-on-fixed-time-interval>`_.  This syntax can be used within the 
    'interval' configuration value to specify complex intervals.


Accessing configuration data

.. code-block:: python3
    :caption: YourAnalysisModule.py

    class YourAnalysisModule(Worker):
    ...
    def callback(self):
        self.logger.info(self.config['worker']['interval'])
        self.logger.info(self.config['worker']['new_value'])