# Minimal OpenLDAP container

This tries to be simple but useful.

# Configuration

## Persistent volume

You'll need to mount a persistent volume at a location like `/data`. Persistent LDAP databases will be stored here.

## Domains

You'll need to configure what domains it serves. For each domain, create an LDIF file and mount it in the `/config`
directory. Use [this example](examples/example.com.ldif) as a starter, and remember to create the database directory
in the persistent volume.

## Schemas

You almost certainly want the schemas included in [schemas.ldif](examples/schemas.ldif). See the
[OpenLDAP docs](https://www.openldap.org/doc/admin24/schema.html#Distributed%20Schema%20Files) for other available
schemas.

## Security

If you want more security than the default, modify [security.ldif](examples/security.ldif) to suit your tastes, and
make it available in `/config` also. If you configure TLS certificates, those will need to be mounted into the
container.

## Ports

The server runs without root privileges, so it binds ports above 1024. You'll need to map host ports to container ports:
`389 -> 1389` and `636 -> 1636`.

## Arguments

The default arguments serve LDAP on a unix socket in the container, and on port 1389. To also serve `ldaps` on port
1636, pass these arguments: `[ "-h", "ldapi:/// ldap://:1389/ ldaps://:1636/" ]`. Note the second argument is one
string with embedded spaces.

## Health checks

TBD. Depending on your configuration, this may be difficult.
