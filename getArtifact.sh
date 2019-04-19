 #wget http://192.168.100.74:8081/repository/maven-central/org/codehaus/plexus/plexus-interpolation/1.14/plexus-interpolation-1.14.pom.sha1

NEXUS_URL=192.168.100.74
NEXUS_PORT=8081
SNAPSHOT_REPOSITORY=maven-snapshots
RELEASE_REPOSITORY=maven-releases
NEXUS_LOGIN=admin
NEXUS_PWD=admin123
NEXUS_AUTH=$NEXUS_LOGIN:$NEXUS_PWD
NEXUS_SOCKET=$NEXUS_URL:$NEXUS_PORT
# Vérification du type de l'artifact passé en argument.

if [[ $1 == *"-SNAPSHOT" ]]; then
# version SNAPSHOT.
	echo "Snapshot"
else
# defaut = version RELEASE.
TRUC="${NEXUS_SOCKET}/service/rest/v1/search/assets?repository=${RELEASE_REPOSITORY}&name=server&maven.extension=jar&version=$1"
echo $TRUC
DL_URL=$(curl -u ${NEXUS_AUTH} -X GET $TRUC \
)
echo $DL_URL
fi

