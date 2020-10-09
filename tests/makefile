
export FGLWSDEBUG=0

#SRV=https://generodemos.dynu.net/z/ws/r
# My local GAS
SRV=http://neilm-predator/g/ws/r
XCF=dfmv2
WS1=menus
WS2=users
WS3=patients

SRC=wsMenus.4gl wsUsers.4gl wsPatients.4gl 

OPTS=--format json --oauth yes --tokenfile dfm.tok

all: $(SRC) CliWSTest.42m

wsMenus.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS1)?openapi.json

wsUsers.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS2)?openapi.json

wsPatients.4gl:
	fglrestful -o $@ $(OPTS) $(SRV)/$(XCF)/$(WS3)?openapi.json

CliWSTest.42m: CliWSTest.4gl
	fglcomp CliWSTest.4gl

clean:
	rm -f $(SRC) *.42?

run: CliWSTest.42m
	fglrun CliWSTest.42m
