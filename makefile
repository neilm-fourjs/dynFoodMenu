
export URL1=https://generodemos.dynu.net/g/ws/r/dfm/menus?openapi.json
export URL2=https://generodemos.dynu.net/g/ws/r/dfm/users?openapi.json
export URL3=https://generodemos.dynu.net/g/ws/r/dfm/patients?openapi.json

all: gar

gar: tests/wsMenus.4gl tests/wsUsers.4gl tests/wsPatients.4gl
	gsmake -t dynFoodBackEnd dynFoodMenu.4pw 

tests/wsMenus.4gl:
	fglrestful -o $@ $(URL1)

tests/wsUsers.4gl:
	fglrestful -o $@ $(URL2)

tests/wsPatients.4gl:
	fglrestful -o $@ $(URL3)

clean:
	find . -name \*.42? -exec rm {} \;
	find . -name \*.gar -exec rm {} \;
