#!/bin/sh

# Set up the config directory and start slapd.

set -e

# Location of *.ldif config files. slapd.ldif is the optional root config file.
CONFIG=/config

# Location of ephemeral config directory.
SLAPD_DIR=/slapd.d

# Erase the contents of the config directory, because the other operations aren't idempotent.
rm -rf "${SLAPD_DIR:?}/"*

# Read slapd.ldif to create the base config.
slapadd -n 0 -F "${SLAPD_DIR}" -l /slapd.ldif < /dev/null

# Start a temporary slapd, listening only on localhost, to load configs into.
slapd -F "${SLAPD_DIR}" -h ldapi:/// -d none &
SLAPD_PID=$!
# shellcheck disable=SC2064
trap "kill $SLAPD_PID" EXIT

# Wait until slapd is ready.
while ! ldapsearch -H ldapi:/// -Y EXTERNAL -b "cn=config" '(objectClass=olcDatabaseConfig)' > /dev/null ; do
    sleep 1
    COUNT=$((COUNT + 1))
    test ${COUNT} -lt 120
done

# Load all the ldif files except slapd.ldif.
for LDIF in "${CONFIG}"/*.ldif ; do
    ldapadd -H ldapi:/// -Y EXTERNAL -f "${LDIF}"
done

# Kill the temporary slapd and start the real one.
kill ${SLAPD_PID}
wait ${SLAPD_PID}
exec slapd -F "${SLAPD_DIR}" -d none "$@"
