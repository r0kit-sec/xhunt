#!/bin/bash

sam build --profile dev --config-file samconfig-dev.toml
sam deploy --profile dev --config-file samconfig-dev.toml
