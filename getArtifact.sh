#!/bin/bash

#Stocke dans des variables les ressources redondantes pour mieux les réutiliser.
NEXUS_URL=192.168.100.74
NEXUS_PORT=8081
SNAPSHOT_REPOSITORY=maven-snapshots
RELEASE_REPOSITORY=maven-releases
NEXUS_LOGIN=admin
NEXUS_PWD=admin123
NEXUS_AUTH=$NEXUS_LOGIN:$NEXUS_PWD
NEXUS_SOCKET=$NEXUS_URL:$NEXUS_PORT
MAVEN_DATA_URL=$NEXUS_SOCKET/repository/maven-snapshots/com/lesformateurs/maven-project/server/$1/maven-metadata.xml
MACHINE_HOTE=192.168.100.128

# Vérification du type de l'artifact passé en argument.
if [[ $1 == *"-SNAPSHOT" ]]; then
# version SNAPSHOT.
# Récupération du dernier snapshot dans le fichier maven-metadata.xml.
LATEST_SNAP=$(curl -X GET $MAVEN_DATA_URL | grep value | head -n 1 | grep -Po "[0-9-.]*")
# Requete pour lister tout les snapshots correspondant a la version demandée.
API_SNAPSHOT_INFO="${NEXUS_SOCKET}/service/rest/v1/search/assets?repository=${SNAPSHOT_REPOSITORY}&name=server&maven.extension=jar&maven.baseVersion=$1"
# Execution de la requete avec l'API REST de Nexus.
INFO_SNAPSHOT=$(curl -u ${NEXUS_AUTH} -X GET $API_SNAPSHOT_INFO)
# A partir des données récupérées précédemment, on affine pour ne recupérer que l'URL de téléchargement.
DL_URL=$(echo "$INFO_SNAPSHOT" | grep -Po "http://[0-9a-zA-Z.:/-]*" | grep "$LATEST_SNAP\.jar")
FILE_NAME="server-$LATEST_SNAP.jar"
else
# defaut = version RELEASE.
# Requete pour lister toutes les releases correspondant a la version demandée.
API_RELEASE_INFO="${NEXUS_SOCKET}/service/rest/v1/search/assets?repository=${RELEASE_REPOSITORY}&name=server&maven.extension=jar&version=$1"
# Execution de la requete avec l'API REST de Nexus.
INFO_RELEASE=$(curl -u ${NEXUS_AUTH} -X GET $API_RELEASE_INFO)
# A partir des données récupérées précédemment, on affine pour ne recupérer que l'URL de téléchargement.
DL_URL=$(echo "$INFO_RELEASE" | grep -Po "http://[0-9a-zA-Z.:/-]*" | grep "$1\.jar")
FILE_NAME="server-$1.jar"
fi
echo $FILE_NAME
echo $DL_URL
wget -P "/tmp" $DL_URL
# Si l'URL est vide (et donc non récupérée), renvoie un message et quitte le script.
if [[ -z "$DL_URL" ]]; then 
	echo "Version non trouvée sur Nexus"
	exit 1001
fi


# Récupération du fichier demandé grâce à l'URL dans le dossier /data/projet
scp  /tmp/$FILE_NAME root@$MACHINE_HOTE:/data/projet