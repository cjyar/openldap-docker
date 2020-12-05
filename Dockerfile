ARG ALPINE_VERSION=3.12
ARG OPENLDAP_VERSION=2.4.50-r0

FROM alpine:${ALPINE_VERSION}

RUN addgroup -g 1000 ldap && \
    adduser -G ldap -D -u 1000 ldap
RUN mkdir -p        /run/openldap /var/lib/openldap/run /slapd.d && \
    chown ldap:ldap /run/openldap /var/lib/openldap/run /slapd.d
ARG OPENLDAP_VERSION
ENV OPENLDAP_VERSION=${OPENLDAP_VERSION}
RUN apk add \
    ca-certificates \
    openldap=${OPENLDAP_VERSION} \
    openldap-back-mdb=${OPENLDAP_VERSION} \
    openldap-clients=${OPENLDAP_VERSION}
COPY init.sh slapd.ldif /

RUN mkdir /data && \
    chown ldap:ldap /data
VOLUME [ "/config", "/data" ]

USER ldap:ldap
ENTRYPOINT [ "/init.sh", "-h", "ldapi:/// ldap://:1389/" ]
