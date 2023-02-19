# Periodic Worker development

This type of Machina worker triggers an analysis periodically.  This is useful for longer-running analysis work that isn't feasible to be run on-demand for every new ingested sample.  One Periodic Worker example is SimilarityAnalysis.  SimilartyAnalysis runs every hour, over all data in the graph, and updates/creates similarity relationships.

## Dockerfile

Install any system dependencies required within your worker's Dockerfile. There are two base image options provided:

Base image options:

* [behren/machina-base-alpine](https://hub.docker.com/repository/docker/behren/machina-base-alpine)
* [behren/machina-base-ubuntu](https://hub.docker.com/repository/docker/behren/machina-base-ubuntu)

```dockerfile linenums="1" title="Dockerfile"
FROM behren/machina-base-ubuntu:latest
...
RUN apt update && apt install libz-dev
...
```

## requirements.txt

Put any Python 3 requirements required by your worker module into requirements.txt  and ensure that you copy requirements.txt into the image and 'pip3 install -r requirements.txt' to install the dependencies

## youranalysismodule.py

This file contains the implementation of your worker module. Subclass the [PeriodicWorker][machina.core.periodic_worker.PeriodicWorker] class, this will ensure your worker module has boilerplate connectivity to the database, and configurations.  The [callback][machina.core.periodic_worker.PeriodicWorker.callback] function fires at the interval your analysis module is configured to.

```python linenums="1" title="youranalysismodule.py"
class YourAnalysisModule(PeriodicWorker):

    def __init__(self, *args, **kwargs):
        super(YourAnalysisModule, self).__init__(*args, **kwargs)
        ...

    def callback(self):
        self.logger.info("I'm firing!")
```


The PeriodicWorker provides some common triggers that can be used to further constrain execution at the configured interval.  

For example, 'n_nodes_added_since' can be used to fire an analysis only if 1,000 new nodes of class type [Elf][machina.core.models.Elf] have been added within the last 1 hour.  These available triggers are documented within the machina core API.

```python linenums="1" title="youranalysismodule.py using trigger"
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
```

## YourAnalysisModule.json (configuration)

This top-level configuration file belongs in machina/configs/workers/youranalysismodule.json.  This file allows for reconfiguration without rebuilding of images or code.  This file
must be named after the worker class name that it corresponds to.  

Configuration data set in this file is made available through the worker module's 'self.config["worker"]' attribute.
Log level is handled by the [PeriodicWorker][machina.core.periodic_worker.PeriodicWorker] base class to automatically adjust the subclass logging level if it is overridden in the configuration.  The interval for invoking [callback][machina.core.periodic_worker.PeriodicWorker.callback] is also handled by the [PeriodicWorker][machina.core.periodic_worker.PeriodicWorker] base class, and can be overridden in the configuration.

```json linenums="1" title="machina/configs/workers/YourAnalyisModule.json.  This module is configured to fire every minute"
{
    "log_level": "debug",
    "interval": "minutely",
    "new_value": "I'm a new configuration!"
}
```

!!! note

    Complex intervals can be set up.  Under the hood, the PeriodicWorker uses [rocketry](https://rocketry.readthedocs.io/) for scheduling.  Rocketry provides a verbose syntax for describing intervals, outlined [here](https://rocketry.readthedocs.io/en/stable/condition_syntax/execution.html?highlight=hourly#execution-on-fixed-time-interval).  This syntax can be used within the 'interval' configuration value to specify complex intervals.


```python linenums="1" title="accessing configuration data"
class YourAnalysisModule(Worker):
    ...
    def callback(self):
        self.logger.info(self.config['worker']['interval'])
        self.logger.info(self.config['worker']['new_value'])
```