Module development
===================================

Each Worker module roughly contains the following files

Dockerfile
-----------------------------------

Base Worker image options

- `behren/machina-base-alpine <https://hub.docker.com/repository/docker/behren/machina-base-alpine>`_  
- `behren/machina-base-ubuntu <https://hub.docker.com/repository/docker/behren/machina-base-ubuntu>`_
- `behren/machina-base-ghidra <https://hub.docker.com/repository/docker/behren/machina-base-ghidra>`_
    - based from 'behren/machina-base-ubuntu'

If Ghidra is not required, using the Alpine base is preferred, because it is lighter
    - The Ubuntu base makes dependency installation easier, at the cost of image size

requirements.txt
-----------------------------------

Put any Python 3 requirements required by your worker module into requirements.txt 
and ensure that you copy requirements.txt into the image and 'pip3 install -r requirements.txt' to install the dependencies

youranalysismodule.py
-----------------------------------

This file contains the implementation of your worker module. subclass the machina.core.worker.Worker class, this will ensure your worker module has boilerplate connectivity to the database, RabbitMQ, and configurations.  
Choose any Machina types (see machina/configs/types.json) your worker module supports, or specify '*' for all.  Examples:

.. code-block:: python3
    :caption: youranalysismodule.py

    class YourAnalysisModule(Worker):
        types = ["zip"] # This worker can handle data typed as 'zip'

        def __init__(self, *args, **kwargs):
            super(YourAnalysisModule, self).__init__(*args, **kwargs)
            ...

.. note::
    If 'behren/machina-base-ghidra' was selected as your base, and Pythonic access to Ghidra is desired, see the GhidraWorker base class in the API documentation

YourAnalysisModule.json (schema)
-----------------------------------

This schema file provides validation constraints that are applied to data incoming to your worker module before it handles the data.  The Schema name must match the
class name that it belongs to (e.g. for the worker module 'AndroguardAnalysis', there must exist a schema in the schemas directory names 'AndroguardAnalysis.json').

Typically, since workers are handling data published by the Identifier, they inherit from the 'binary.json' schema. Additional input requirements can be specified in "properties"

.. code-block:: json
    :caption: YourAnalysisModule.json 

    {
        "allOf": [{ "$ref": "binary.json"}],
        "properties": {
    }

YourAnalysisModule.json (configuration)
-----------------------------------

This top-level configuration file belongs in machina/config/youranalysismodule.json.  This file allows for reconfiguration without rebuilding of images or code.  This file
must be named after the worker class name that it corresponds to.  Configuration data set in this file is made available through the worker module's 'self.config["worker"] attribute.
Log level is handled by the Worker base class to automatically adjust the subclass logging level.


.. code-block:: json
    :caption: YourAnalysisModule.json

    {
        "log_level": "debug",
        "hash_algorithms": ["md5", "sha256"]
    }

Accessing configuration data

.. code-block:: python3
    :caption: YourAnalysisModule.py

    class YourAnalysisModule(Worker):
        types = ["zip"] 
    ...
    def callback(self, data, properties):
        self.logger.info(self.config['worker']['hash_algorithms'])

Other notes
-----------------------------------

Republishing
++++++++++

Worker modules are not intended to create new objects (e.g. files, binary data) in the database directly, only update elements or create edges (relationships).  
They should publish any extracted data of interest to the Identifier queue so that it re-enters the pipeline, e.g.:

.. code-block:: python3
    :caption: YourAnalysisModule.py

    class YourAnalysisModule(Worker):
        next_queues = ['Identifier']
        ...
        
        def callback(self, data, properties):
            ...
            self.publish_next(json.dumps(data)) # publish to queues configured in 'next_queues'

OR 

.. code-block:: python3
    :caption: YourAnalysisModule.py

    class MyWorker(Worker):
        ...
        def callback(self, data, properties):
            ...
            self.publish(json.dumps(data), queues=['Identifier']) # publish to 'Identifier'

When updating elements in the database, it is highly recommended to use the the Worker base class' update_node or create_edge functions.  These functions attempt to avoid updating a stale/out-of-date handle to a database element. 

Retyping
++++++++++

identified with cursory static analysis.  Sometimes it requires a bit of context, e.g. an Android APK is technically a zip file, and can only really be identified by peering into the zip and searching for common APK files.  Only then can we retype the binary as an APK. This burden should be on the zip module to discover, not the identifier.

The snippet below is an example of when the Zip analysis module detects that it is actually working on an APK.  The Zip module resubmits most of the same data that consumed from the queue, except it manually specifies the 'type' to 'apk', which the Identifier will take at face value.

.. code-block:: python3
    :caption: YourAnalysisModule.py

    def callback(self, data, properties):
        ...
        body = {
            "data": data_encoded,
            "origin": {
                "ts": data['ts'],
                "md5": data['hashes']['md5'],
                "id": data['id'], #I think this is the only field needed, we can grab the unique node based on id alone
                "type": data['type']
            },
            'type': 'apk'
        }

    self.publish(json.dumps(data), queues=['Identifier']) # publish to 'Identifier'

```  