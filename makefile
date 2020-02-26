
export ANDROID_SDK_ROOT=/opt/Android/sdk2019
export GMADIR=/opt/fourjs/gma-1.40.09
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

export PATH+=$(GMADIR);$(GMATOOLSDIR);$(ANDROID_SDK_ROOT)/tools;$(ANDROID_SDK_ROOT)/tools/bin;$(ANDROID_SDK_ROOT)/platform-tools
export JAVA_JDK=$(JAVA_HOME)
export URL1=https://generodemos.dynu.net/g/ws/r/dfm/menus?openapi.json
export URL2=https://generodemos.dynu.net/g/ws/r/dfm/users?openapi.json
export URL3=https://generodemos.dynu.net/g/ws/r/dfm/patients?openapi.json

all: gar

gar: 
	gsmake -t dynFoodBackEnd dynFoodMenu.4pw 

gma: gar
	gsmake -t dynFoodMenu_GMA dynFoodMenu.4pw 

gmaur: gar
	gsmake -t dynFoodMenuUR_GMA dynFoodMenu.4pw 

gmiur: gar
	gsmake -t dynFoodMenuUR_GMI dynFoodMenu.4pw 

testbin/CliWSTest.42r: tests/CliWSTest.4gl tests/wsMenus.4gl tests/wsUsers.4gl tests/wsPatients.4gl
	gsmake -t CliWSTest dynFoodMenu.4pw

tests/wsMenus.4gl:
	fglrestful -o $@ $(URL1)

tests/wsUsers.4gl:
	fglrestful -o $@ $(URL2)

tests/wsPatients.4gl:
	fglrestful -o $@ $(URL3)

clean:
	find . -name \*.42? -exec rm {} \;
	find . -name \*.gar -exec rm {} \;
