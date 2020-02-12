#!/bin/bash
# If the user doesn't have permissions to deploy apps then use sudo
# Args:
#  Server No : defaults to 1
#  Gar name : defaults to dynFoodBackEnd
#  GenVer : defaults to 320

function localDeploy() {
	GAR=$1
	VER=$2
	USER=$3

	# Set the GAS environment
	. /opt/fourjs/gas$VER/envas

	# Define the command using our custom XCF
	if [ -e $FGLASDIR/etc/isv_as$VER.xcf ]; then
		CMD="$FGLASDIR/bin/gasadmin gar -f $FGLASDIR/etc/isv_as$VER.xcf"
	else
		CMD="$FGLASDIR/bin/gasadmin gar"
	fi
	if [ ! -z "$USER" ]; then
		CMD="sudo -u $USER $CMD"
	fi
	
	echo -e "\n attempt to disable previous version of app ..."
	echo "$CMD --disable-archive $GAR"
	$CMD --disable-archive $GAR
	if [ $? -eq 0 ]; then
		echo -e "\n attempt to undeploy previous version of app ..."
		echo	"$CMD --undeploy-archive $GAR"
		$CMD --undeploy-archive $GAR
	fi
	
	#echo -e "\n List archives:"
	#$CMD --list-archives
	
	echo -e "\n attempt to clean archives ..."
	echo "$CMD --clean-archives --yes"
	$CMD --clean-archives --yes
	
	echo -e "\n attempt to install new version of app ..."
	echo "$CMD --deploy-archive $GAR.gar"
	$CMD --deploy-archive $GAR.gar
	
	if [ $? -eq 0 ]; then
		echo -e "\n attempt to enable app ..."
		echo "$CMD --enable-archive $GAR"
		$CMD --enable-archive $GAR
	else
		echo "Deploy Failed!"
	fi
}

function remoteDeploy() {
	GAR=$1
	VER=$2
	USER=$3
	CMD="./deploy_app.sh 0 $GAR $VER $USER"

	echo "Deploying ${GAR}.gar to $HOST ..."
	# Copy the gar to the server
	scp -P $PORT ${GAR}.gar $HOST:
	# Run the deploy script to use gasadmin to re-deploy the gar
	ssh -p $PORT $HOST $CMD
}

# Main code

PORT=22
SRV=${1:-1}
APP=${2:-dynFoodBackEnd}
VER=${3:-320}
USER=${4}

case $SRV in
0)
	GAR=$APP
	HOST=local
;;
1)
	HOST=pi@generodemos.dynu.net
	PORT=999
;;
2)
	HOST=ryan-4js.com
	PORT=999
;;
3)
	HOST=demos.4js-emea.com
	USER=fourjs
;;
4)
	HOST=$5
;;
esac

GAR=${APP}

echo "Srv: $SRV Host: $HOST Gar: $GAR Ver: $VER"

if [ ! -e ${GAR}.gar ]; then
	echo "${GAR}.gar missing!"
	exit 1
fi

if [ "$HOST" == "local" ]; then
	localDeploy $GAR $VER $USER
else
	remoteDeploy $GAR $VER $USER
fi

echo "Finished."

