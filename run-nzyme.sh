#! /bin/bash

# Parse and replace env vars to generate a new configuration with updated env var values
envsubst < /etc/nzyme/nzyme.conf.template > /etc/nzyme/nzyme.conf
sleep 2
# Test bootstrapping
# /usr/local/bin/nzyme --bootstrap-test
echo "NZYME_JAVA_OPTS=\"${NZYME_JAVA_OPTS}\"" > /etc/default/nzyme
# Migrate database
/usr/local/bin/nzyme --migrate-database
# Run nzyme
/usr/local/bin/nzyme