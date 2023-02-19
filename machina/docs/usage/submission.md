# Submission

## CLI

machinacli.py can be used to submit either a single file or a batch of individual files:

```bash linenums="1"
python3 bin/machinacli.py submit /usr/bin/ls /usr/bin/ps
```

Alternatively, if there are too many files to conveniently list as command line options, files can compressed or archived and submitted.  Machina's decompression/unarchiving modules would then handle the unpacking and resubmission automatically to the system:

```bash linenums="1"
zip test.zip /usr/bin/ls /usr/bin/ps
python3 bin/machinacli.py submit test.zip
```

As analyses are completed, they are viewable in the Neo4J dashboard described within the 'Administration' section.


## JSON 

Optionally, you can publish your own message to the RabbitMQ Server, with the routing key set to 'Identifier' and a JSON body containing a base-64 encoded payload like the following:

```json linenums="1"
{"data":  "<b64encoded_data>"}
```

Or, to assert a type (must be available in the 'available_types' configuration within machina/configs/types.json), provide it in the 'type' key-value pair.  Providing this key forces the Identifier to skip type resolution and accept your own:

```json linenums="1"
{
    "data": "<b64encoded_data>",
    "type": "apk"
}
```