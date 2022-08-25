
# This script attempts to setup a GBC dev environment
#
# Example:
# ./gbc-setup.sh 1.00.41 201711301722

set_default_build()
{
LAST=$(ls -1 $GBCPROJECTDIR/fjs-${GBC}*-project.zip | tail -1 )
VER=$(echo $LAST | cut -d'-' -f3)
BLD=$(echo $LAST | cut -d'-' -f4)
}

BASE=$(pwd)

GBC=gbc
VER=$1
BLD=$2

if [ -z $GBCPROJECTDIR ]; then
	echo "WARNING: GBCPROJECTDIR is not set to location of GBC project zip file(s)"
	GBCPROJECTDIR=~/FourJs_Downloads/GBC
	echo "Defaulting GBCPROJECTDIR to $GBCPROJECTDIR"
fi
if [ ! -e $GBCPROJECTDIR ]; then
	echo "$GBCPROJECTDIR doesn't exist, aborting!"
	exit 1
fi

if [ $# -ne 2 ]; then
	set_default_build
fi

if [ -z $VER ]; then
	echo "VER is not set! aborting!"
	echo "./gbc-setup.sh 1.00.38 build201707261501"
	exit 1
fi
if [ -z $BLD ]; then
	echo "BLD is not set! aborting!"
	echo "./gbc-setup.sh 1.00.38 build201707261501"
	exit 1
fi

echo "VER=$VER BLD=$BLD"

SRC="$GBCPROJECTDIR/fjs-$GBC-$VER-$BLD-project.zip"

SAVDIR=$(pwd)
cd ..

if [ -d gbc-current ]; then
	BLDDIR=gbc-current
else
	BLDDIR=gbc-$VER
fi

if [ ! -d $BLDDIR ]; then
	mkdir -p $BLDDIR
	if [ ! -e "$SRC" ]; then
		echo "Missing $SRC Aborting!"
		exit 1
	fi
	unzip $SRC
	ln -s gbc-$VER gbc-current
fi

cd gbc-current

npm install
npm install grunt-cli
npm install bower
npm audit fix
grunt deps

cd $SAVDIR
if [ ! -d gbc-current ]; then
	ln -s ../gbc-current ./gbc-current
fi
