#! /bin/bash

# Parse and replace env vars to generate a new configuration with updated env var values
envsubst < /etc/nzyme/nzyme.conf.template > /etc/nzyme/nzyme.conf

# Run nzyme
/usr/share/nzyme/bin/nzyme