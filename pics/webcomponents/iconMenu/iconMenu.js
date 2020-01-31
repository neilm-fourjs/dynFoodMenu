var myProps
var has_focus=false;
var clicked=false;
var val1;


function menuClicked(l_action) {
//	alert(l_action);
	gICAPI.Action(l_action);
}

// This function is called by the Genero Client Container
// so the web component can initialize itself and initialize
// the gICAPI handlers
onICHostReady = function(version) {

	if ( version != 1.0 ) {
		alert('Invalid API version');
		return;
	}

	gICAPI.onFocus = function( polarity ) {
		if ( polarity && clicked ) {
			//alert('onFocus');
			clicked = false;
		}
		has_focus = polarity;
	}

	gICAPI.onProperty = function(props) {
		myProps = eval("(" + props + ")");
	}

	gICAPI.onData = function( data ) {
		val1 = eval("(" + data + ")");
		var menu="";
	//	alert(val1.menu[1].text);
		document.getElementById("debug").innerHTML="gicapi:"+data;
		for (i in val1.menu) {
		//	alert(i);
			menuitemdiv = "<div id=\"menuitem\" onclick=\"menuClicked('"+val1.menu[i].action+"')\">";
			menu += menuitemdiv+"<img src=\""+val1.menu[i].image+"\" class=\"menuimg\"><br>"+val1.menu[i].text+"</div>";
		}
		document.getElementById("menu").innerHTML=menu;
		gICAPI.SetFocus();
		clicked = true;
	}
}

