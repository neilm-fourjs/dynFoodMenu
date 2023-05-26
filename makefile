
#export ANDROID_SDK_ROOT=/opt/Android/sdk2019
#export GMADIR=/opt/fourjs/gma-1.40.09
#export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#export JAVA_JDK=$(JAVA_HOME)

# Test server
export SERVER=https://generodemos.dynu.net/g

export PATH+=$(GMADIR);$(GMATOOLSDIR);$(ANDROID_SDK_ROOT)/tools;$(ANDROID_SDK_ROOT)/tools/bin;$(ANDROID_SDK_ROOT)/platform-tools
export URL1=$(SERVER)/ws/r/dfm/menus?openapi.json
export URL2=$(SERVER)/ws/r/dfm/users?openapi.json
export URL3=$(SERVER)/ws/r/dfm/patients?openapi.json

export GBC_USER=gbc-foodMenu
export GBC_USER_DIR=..
export GBCDISTPATH=../gbc-current/dist/customization
export FGLGBCDIR=$(GBCDISTPATH)/$(GBC_USER)
export FGLLDPATH=../binCommon
export FGLDBPATH=$(FGLLDPATH)
export FGLRESOURCEPATH=../etc:$(FGLLDPATH)
export FGLPROFILE=../etc/fglprofile.gst
export FGLIMAGEPATH=../pics
export FGLWSDEBUG=9
export MYWSDEBUG=9
export WSSERVER=localv2

all: gar

gar: 
	gsmake -t dynFoodBackEnd dynFoodMenu$(GENVER).4pw 

gma: gar
	gsmake -t dynFoodMenu_GMA dynFoodMenu$(GENVER).4pw 

gmaur: gar
	gsmake -t dynFoodMenuUR_GMA dynFoodMenu$(GENVER).4pw 

gmiur: gar
	gsmake -t dynFoodMenuUR_GMI dynFoodMenu$(GENVER).4pw 

testbin/CliWSTest.42r: tests/CliWSTest.4gl tests/wsMenus.4gl tests/wsUsers.4gl tests/wsPatients.4gl
	gsmake -t CliWSTest dynFoodMenu$(GENVER).4pw

tests/wsMenus.4gl:
	fglrestful -o $@ $(URL1)

tests/wsUsers.4gl:
	fglrestful -o $@ $(URL2)

tests/wsPatients.4gl:
	fglrestful -o $@ $(URL3)

clean:
	find . -name \*.42? -exec rm {} \;
	find . -name \*.gar -exec rm {} \;

run:
	cd bin && fglrun dynFoodMenu.42r $(WSSERVER) > ../debug.$(WSSERVER) 2>&1
