
export FGLLDPATH=../bin
export FGLWSDEBUG=9
export MYWSDEBUG=0

#SRV=https://generodemos.dynu.net/z/ws/r
# My local GAS
SRV=http://neilm-predator/g/ws/r
XCF=dfmv2
WS1=menus
WS2=users
WS3=patients
CFG=localv2
TOK=dfm.tok

LIB=../bin/wsAuthLib.42m

SRC=wsMenus.4gl wsUsers.4gl wsPatients.4gl 

OPTS=--format json --oauth yes --tokenfile $(TOK)
#OPTS=--format json 

all: myGetToken.42m OAuthAPI.42m  $(TOK) $(SRC) CliWSTest.42m

OAuthAPI.42m: OAuthAPI.4gl
	fglcomp $^

myGetToken.42m: myGetToken.4gl $(LIB)
	fglcomp myGetToken.4gl

$(TOK): myGetToken.42m
	fglrun myGetToken $(CFG) $(TOK)

wsMenus.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS1)?openapi.json

wsUsers.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS2)?openapi.json

wsPatients.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS3)?openapi.json

CliWSTest.42m: CliWSTest.4gl $(LIB)
	fglcomp CliWSTest.4gl

clean:
	rm -f $(SRC) *.42? *.tok

run: CliWSTest.42m
	fglrun CliWSTest.42m $(CFG)
