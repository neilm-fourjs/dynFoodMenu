
export FGLWSDEBUG=0

#SRV=https://generodemos.dynu.net/z/ws/r
# My local GAS
SRV=http://neilm-predator/g/ws/r
XCF=dfmv2
WS1=menus
WS2=users
WS3=patients
TOK=dfm.tok

SRC=wsMenus.4gl wsUsers.4gl wsPatients.4gl 

OPTS=--format json --oauth yes --tokenfile $(TOK)

all: myGetToken.42m $(TOK) $(SRC) CliWSTest.42m

myGetToken.42m: myGetToken.4gl libWSAuth.4gl
	fglcomp myGetToken.4gl

$(TOK): myGetToken.42m
	fglrun myGetToken $(TOK)

wsMenus.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS1)?openapi.json

wsUsers.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS2)?openapi.json

wsPatients.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS3)?openapi.json

CliWSTest.42m: CliWSTest.4gl libWSAuth.4gl
	fglcomp CliWSTest.4gl

clean:
	rm -f $(SRC) *.42? *.tok

run: CliWSTest.42m
	fglrun CliWSTest.42m
