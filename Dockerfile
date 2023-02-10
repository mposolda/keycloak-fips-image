FROM quay.io/keycloak/keycloak:nightly as builder

ADD files /tmp/files/

WORKDIR /opt/keycloak
RUN cp /tmp/files/*.jar /opt/keycloak/providers/
RUN cp /tmp/files/keycloak-fips.keystore.* /opt/keycloak/bin/

RUN /opt/keycloak/bin/kc.sh build --fips-mode=enabled

FROM quay.io/keycloak/keycloak:nightly
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]