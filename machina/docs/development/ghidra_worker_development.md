# Ghidra Worker development

## Dockerfile


Install any additional system dependencies required within your worker's Dockerfile.

Base image options:

- [behren/machina-base-ghidra](https://hub.docker.com/repository/docker/behren/machina-base-ghidra)

Dockerfile example:

```dockerfile linenums="1" title="Dockerfile"
:caption: example dockerfile

FROM behren/machina-base-ghidra:latest
...
RUN apt update && apt install libz-dev
...
```

## requirements.txt

Put any Python 3 requirements required by your worker module into requirements.txt and ensure that you copy requirements.txt into the image and 'pip3 install -r requirements.txt' to install the dependencies.

## youranalysismodule.py

This file contains the implementation of your worker module. subclass the machina.core.ghidra_worker.GhidraWorker class, this will ensure your worker module has boilerplate connectivity to the database, RabbitMQ, and configurations.  
Choose any Machina types (see 'machina/configs/types.json') your worker module supports, or specify '*' for all. 


The 'callback' function provides your analysis implementation with data that your module is configured to support.  This callback function fires whenever the system identifies a compatible sample.


```python linenums="1"
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
```

## YourAnalysisModule.json (schema)

This schema file provides validation constraints that are applied to data incoming to your worker module before it handles the data.  The Schema name must match the
class name that it belongs to (e.g. for the worker module 'AndroguardAnalysis').  This file belongs at the top level of your worker's directory, and must be copied within the Dockerfile.

Typically, since workers are handling data published by the Identifier, they inherit from the 'binary.json' schema. Additional input requirements can be specified in "properties"

```json linenums="1" title="images/youranalysismodule/YourAnalyisModule.json.  This module contains no additional input validation"
{
    "allOf": [{ "$ref": "binary.json"}],
    "properties": {}
}
```

## YourAnalysisModule.json (configuration)

This top-level configuration file belongs in machina/configs/workers/youranalysismodule.json.  This file allows for reconfiguration without rebuilding of images or code.  This file
must be named after the worker class name that it corresponds to.  Configuration data set in this file is made available through the worker module's 'self.config["worker"] attribute.
Log level is handled by the Worker base class to automatically adjust the subclass logging level if it is overridden in the configuration.

```json linenums="1" title="machina/configs/workers/YourAnalyisModule.json.  This module contains additional configurations for analysis timeout"
{
    "log_level": "debug",
    "analysis_timeout_per_file": 600
}
```

```python linenums="1" title="accessing configuration data"
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
```