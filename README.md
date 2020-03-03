# A Dynamic Food Menu Mobile App
This demo requires Genero 3.20 or above.

The goal was to generate the screen and the dialog dynamically based on the data provided from the server.

The demo includes:
* A backend web REST service.
* A simple webcomponent for an 'icon' based selection screen based on data from the server
* A simple custom GBC for running the appliction in a browser and using Universal Rendering in the GDC/Mobile.

Flow:
1. Login
2. Select Ward / Bed
3. Select the 'Menu'  from that menu the app requests the 'food menu' from the server and generates the form and input.
4. Make food selections
5. Confirm the order so it's sent to the server
6. Return to step 3 to order other meals

There are a few programs provided:
* dynFoodMenu - The main application
* dynFoodRest - RESTful web service for providing the menus.
* dynFoodMenu2 - (see tests in the project) a single .4gl example of just the form generation and input based on a JSON data set.

## Running on Android: Universal Rendering
### Login
![ss1u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss1ur.png "SS1UR")
### Registar a new operator
![ss2u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss2ur.png "SS2UR")
![ss3u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss3ur.png "SS3UR")
### Select a patient - swipe across to see the details
![ss31u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss31ur.png "SS31UR")
![ss32u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss32ur.png "SS32UR")
### Dynamic menu choice
![ss4u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss4ur.png "SS4UR")
### Dynamic food selection
![ss5u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss5ur.png "SS5UR")
![ss6u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss6ur.png "SS5UR")
### Place an order
![ss7u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss7ur.png "SS7UR")
![ss8u](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss8ur.png "SS8UR")

## Running on Android: Native Rendering
![ss1n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss1nat.png "SS1NAT")
![ss2n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss2nat.png "SS2NAT")
![ss3n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss3nat.png "SS3NAT")
![ss4n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss4nat.png "SS4NAT")
![ss5n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss5nat.png "SS5NAT")
![ss6n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss6nat.png "SS6NAT")
![ss7n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss7nat.png "SS7NAT")
![ss8n](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss8nat.png "SS8NAT")

## Running in the GBC ( Chrome )
![ss1b](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss1gbc.png "SS1B")
![ss2b](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss2gbc.png "SS2B")
![ss3b](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss3gbc.png "SS3B")
![ss4b](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss4gbc.png "SS4B")
![ss5b](https://github.com/neilm-fourjs/dynFoodMenu/raw/master/screenshots/ss5gbc.png "SS5B")
