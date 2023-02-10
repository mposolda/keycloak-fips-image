#
# Copyright 2023 Red Hat, Inc. and/or its affiliates
#  and other contributors as indicated by the @author tags.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#

#!/bin/bash -e

# Copy files
if [ x"$KEYCLOAK_SOURCES" == "x" ]; then
    echo "Environment variable KEYCLOAK_SOURCES must be set and pointing to codebase of keycloak main repository";
    exit 1;
fi;
echo "KEYCLOAK_SOURCES=$KEYCLOAK_SOURCES";

MAVEN_REPO_HOME=$HOME/.m2/repository
echo "MAVEN_REPO_HOME=$MAVEN_REPO_HOME";

RESOLVED_NAME="$(readlink -f "$0")"
DIRNAME="$(dirname "$RESOLVED_NAME")"
echo "DIRNAME: $DIRNAME";

if [ x"$KEYSTORE_FORMAT" == "x" ]; then
    KEYSTORE_FORMAT = 'pkcs12';
fi;
export KEYSTORE_FILE=keycloak-fips.keystore.$KEYSTORE_FORMAT;
echo "$KEYSTORE_FORMAT: $KEYSTORE_FORMAT";
echo "$KEYSTORE_FILE: $KEYSTORE_FILE";

cd $DIRNAME
BCFIPS_VERSION=1.0.2.3
BCTLSFIPS_VERSION=1.0.14
BCPKIXFIPS_VERSION=1.0.7
mkdir files
cp $MAVEN_REPO_HOME/org/bouncycastle/bc-fips/$BCFIPS_VERSION/bc-fips-$BCFIPS_VERSION.jar ./files/
cp $MAVEN_REPO_HOME/org/bouncycastle/bctls-fips/$BCTLSFIPS_VERSION/bctls-fips-$BCTLSFIPS_VERSION.jar ./files/
cp $MAVEN_REPO_HOME/org/bouncycastle/bcpkix-fips/$BCPKIXFIPS_VERSION/bcpkix-fips-$BCPKIXFIPS_VERSION.jar ./files/
cp $KEYCLOAK_SOURCES/testsuite/integration-arquillian/servers/auth-server/common/fips/$KEYSTORE_FILE ./files/

podman build . -t my-fips-keycloak

# Delete temporary files used during build of docker image
rm -rf files

