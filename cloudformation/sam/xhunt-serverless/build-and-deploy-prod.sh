#!/bin/bash

sam build --profile prod --config-file samconfig.toml
sam deploy --profile prod --config-file samconfig.toml
