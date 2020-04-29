# A Dynamic Food Menu Mobile App
This demo requires Genero 3.20 or above.

The goal was to generate the screen and the dialog dynamically based on the data provided from the server.

## The demo includes
* A backend web REST service.
* A simple webcomponent for an 'icon' based selection screen based on data from the server
* A simple custom GBC for running the appliction in a browser and using Universal Rendering in the GDC/Mobile.

## Flow
1. Login
2. Select Ward / Bed
3. Select the 'Menu'  from that menu the app requests the 'food menu' from the server and generates the form and input.
4. Make food selections
5. Confirm the order so it's sent to the server
6. Return to step 3 to order other meals

## There are a few programs provided
* dynFoodMenu - The main application
* dmf_ws - RESTful web service for providing the users/menus/patients
* dynFoodMenu2 - (see tests in the project) a single .4gl example of just the form generation and input based on a JSON data set.

The bulk of the business logic is handled by 3 modules:
* Menus : handles the menus, menu items an placing an order
* Users : handles the application users and the security token
* Patients : handles getting the list of wards and patients

Those modules can be used by the frontend program and by the backend web services to handle data access via a database connection or via the published web services depending on the need.

## Custom GBC build on Linux.
This assumes you have installed the GBC Prerequisites and have downloaded the current GBC project zip file and either placed it in a folder of ~/FourJs_Downloads/GBC or have set GBCPROJECTDIR to the folder containing that zip file.
```
cd gbc_foodMenu
./gbc-setup.sh
make
```

## Android SDK install on Linux ( avoiding download of full Android Studio IDE )
Ideally you can just download the command line tools and use those to get the required Android elements.
These are the steps I did on a clean fresh install of Kubuntu 20.04 LTS.
```
cd ~/Downlods
wget https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip
sudo mkdir /opt/AndroidSDK
sudo chmod  777 /opt/AndroidSDK
cd /opt/AndroidSDK/
unzip ~/Downlods/commandlinetools-linux-6200805_latest.zip 
export ANDROID_HOME=/opt/AndroidSDK
export PATH=$PATH:$ANDROID_HOME/tools/bin
yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses
sdkmanager --sdk_root=${ANDROID_HOME} "tools"
```
Once this is done you can use the GST 'Android Tools / Auto-configure Android SDK' option.
NOTE: The Android SDK does take a LOT of disk space ( allow for about 10GB ! )

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
