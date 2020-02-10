
export URL=https://generodemos.dynu.net/g/ws/r/dyn/dynFoodRest

all: tests/wsBackEnd.4gl
	gsmake dynFoodMenu.4pw

tests/wsBackEnd.4gl:
	fglrestful -o $@ $(URL)?openapi.json

clean:
	find . -name \*.42? -exec rm {} \;
	find . -name \*.gar -exec rm {} \;
