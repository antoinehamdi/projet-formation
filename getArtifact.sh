 #wget http://192.168.100.74:8081/repository/maven-central/org/codehaus/plexus/plexus-interpolation/1.14/plexus-interpolation-1.14.pom.sha1

NEXUS_URL=192.168.100.74
NEXUS_PORT=8081
SNAPSHOT_REPOSITORY=maven-snapshots
RELEASE_REPOSITORY=maven-releases
NEXUS_LOGIN=admin
NEXUS_PWD=admin123
NEXUS_AUTH=$NEXUS_LOGIN:$NEXUS_PWD
NEXUS_SOCKET=$NEXUS_URL:$NEXUS_PORT
MAVEN_DATA_URL=$NEXUS_SOCKET/repository/maven-snapshots/com/lesformateurs/maven-project/server/$1/maven-metadata.xml
echo $MAVEN_DATA_URL
# Vérification du type de l'artifact passé en argument.

if [[ $1 == *"-SNAPSHOT" ]]; then
# version SNAPSHOT.
LATEST_SNAP=$(curl -X GET $MAVEN_DATA_URL | grep value | head -n 1 | grep -Po "[0-9-.]*")
echo $LATEST_SNAP
API_SNAPSHOT_INFO="${NEXUS_SOCKET}/service/rest/v1/search/assets?repository=${SNAPSHOT_REPOSITORY}&name=server&maven.extension=jar&version=$1"
INFO_SNAPSHOT=$(curl -u ${NEXUS_AUTH} -X GET $API_SNAPSHOT_INFO)
DL_SNAPSHOT_URL=$(echo "$INFO_SNAPSHOT" | grep -Po "http://[0-9a-zA-Z.:/-]*" | grep "$1\.jar")
else
# defaut = version RELEASE.
API_RELEASE_INFO="${NEXUS_SOCKET}/service/rest/v1/search/assets?repository=${RELEASE_REPOSITORY}&name=server&maven.extension=jar&version=$1"
INFO_RELEASE=$(curl -u ${NEXUS_AUTH} -X GET $API_RELEASE_INFO)
DL_RELEASE_URL=$(echo "$INFO_RELEASE" | grep -Po "http://[0-9a-zA-Z.:/-]*" | grep "$1\.jar")

fi

echo $DL_RELEASE_URL