# keycloak-fips-image
Base support for Keycloak FIPS image

NOTE: This project is WIP and it is not officially supported and guaranteed to work

1) It is assumed that:
- you use this project on FIPS enabled RHEL 9 system
- you have java 17 and mvn installed on your host and youh have `podman` (podman is installed by default on RHEL)
- It is assumed you already did Keycloak build in your laptop, so you have BCFIPS artifacts in your mvn repo

The assumption is needed because we want container to be in FIPS mode. Which in RHEL8 (or RHEL9) assumes that the `host server` is also in FIPS mode.
Container will then "inherit" FIPS mode from the parent host and configure all the stuff (especially openjdk etc) accordingly.
See this docs for the details: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/security_hardening/using-the-system-wide-cryptographic-policies_security-hardening#enabling-fips-mode-in-a-container_using-the-system-wide-cryptographic-policies

2) You need to set environment variable KEYCLOAK_SOURCES before using this. Sources can be obtained from github. So for example:
```
export KEYCLOAK_SOURCES=/home/mposolda/IdeaProjects/keycloak
```

3) Set variable KEYSTORE_FORMAT to `pkcs12` or `bcfks`. The `pkcs12` works just in BCFIPS non-approved mode. Use one of those lines:
```
export KEYSTORE_FORMAT=pkcs12;
export KEYSTORE_FORMAT=bcfks;
```

4) Run the script to build docker image. Image will have name `my-fips-keycloak`
```
./build-fips-keycloak-docker-image.sh
```

5) Run the image with something like this:
```
podman run --name my-fips-keycloak -p 8443:8443 \
        -e KEYCLOAK_ADMIN=adminadminadmin -e KEYCLOAK_ADMIN_PASSWORD=adminadminadmin \
        my-fips-keycloak \
        start --fips-mode=enabled --hostname=localhost \
        --https-key-store-file=/opt/keycloak/bin/keycloak-fips.keystore.$KEYSTORE_FORMAT --https-key-store-type=$KEYSTORE_FORMAT   --https-key-store-password=passwordpassword \
        --log-level=INFO,org.keycloak.common.crypto:TRACE,org.keycloak.crypto:TRACE
```

6) Go to https://localhost:8443/admin and login as user `adminadminadmin` with the password `adminadminadmin`

7) Cleanup after server stop:
```
podman stop my-fips-keycloak
podman rm my-fips-keycloak
```

