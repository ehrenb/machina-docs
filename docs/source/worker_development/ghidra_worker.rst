Ghidra Worker Development
===================================

This type of Machina worker is identical to the Worker type, except it extends it to contain additional functionality for interacting with Ghidra's analyzeHeadless interface.


Dockerfile
-----------------------------------

Install any additional system dependencies required within your worker's Dockerfile.

Base image options:

- `behren/machina-base-ghidra <https://hub.docker.com/repository/docker/behren/machina-base-ghidra>`_

Dockerfile example:

.. code-block:: dockerfile
    :caption: example dockerfile

    FROM behren/machina-base-ghidra:latest
    ...
    RUN apt update && apt install libz-dev
    ...


requirements.txt
-----------------------------------

Put any Python 3 requirements required by your worker module into requirements.txt 
and ensure that you copy requirements.txt into the image and 'pip3 install -r requirements.txt' to install the dependencies

youranalysismodule.py
-----------------------------------

This file contains the implementation of your worker module. subclass the machina.core.ghidra_worker.GhidraWorker class, this will ensure your worker module has boilerplate connectivity to the database, RabbitMQ, and configurations.  
Choose any Machina types (see 'machina/configs/types.json') your worker module supports, or specify '*' for all. 


The 'callback' function provides your analysis implementation with data that your module is configured to support.  This callback function fires whenever the system identifies a compatible sample.

Examples:

.. code-block:: python3
    :caption: youranalysismodule.py handles elf data

    class YourAnalysisModule(GhidraWorker):
        types = ["elf"]

        def __init__(self, *args, **kwargs):
            super(YourAnalysisModule, self).__init__(*args, **kwargs)
            ...

        def callback(self, data, properties):

            # resolve path
            target = self.get_binary_path(data['ts'], data['hashes']['md5'])
            self.logger.info(f"resolved path: {target}")

            self.analyze_headless(
                str(Path(target).parent),
                f'proj-{data["hashes"]["md5"]}-{self.cls_name}',
                import_files=[target]
            )

YourAnalysisModule.json (schema)
-----------------------------------

This schema file provides validation constraints that are applied to data incoming to your worker module before it handles the data.  The Schema name must match the
class name that it belongs to (e.g. for the worker module 'AndroguardAnalysis', there must exist a schema in the schemas directory names 'AndroguardAnalysis.json').

Typically, since workers are handling data published by the Identifier, they inherit from the 'binary.json' schema. Additional input requirements can be specified in "properties"

.. code-block:: json
    :caption: YourAnalysisModule.json 

    {
        "allOf": [{ "$ref": "binary.json"}],
        "properties": {}
    }

YourAnalysisModule.json (configuration)
-----------------------------------

This top-level configuration file belongs in machina/configs/workers/youranalysismodule.json.  This file allows for reconfiguration without rebuilding of images or code.  This file
must be named after the worker class name that it corresponds to.  Configuration data set in this file is made available through the worker module's 'self.config["worker"] attribute.
Log level is handled by the Worker base class to automatically adjust the subclass logging level if it is overridden in the configuration.


.. code-block:: json
    :caption: YourAnalysisModule.json

    {
        "log_level": "debug",
        "analysis_timeout_per_file": 600
    }

Accessing configuration data

.. code-block:: python3
    :caption: YourAnalysisModule.py

    class YourAnalysisModule(Worker):
        types = ["elf"] 
    ...
    def callback(self, data, properties):
        self.logger.info(self.config['worker']['analysis_timeout_per_file'])

        # resolve path
        target = self.get_binary_path(data['ts'], data['hashes']['md5'])
        self.logger.info(f"resolved path: {target}")

        self.analyze_headless(
            str(Path(target).parent),
            f'proj-{data["hashes"]["md5"]}-{self.cls_name}',
            import_files=[target],
            analysis_timeout_per_file=self.config['worker']['analysis_timeout_per_file']
        )
