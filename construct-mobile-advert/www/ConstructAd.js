var exec = require('cordova/exec');

var CLASS_NAME = "ConstructAd";

exports.CreateBannerAdvert = function CreateBannerAdvert (id, size, debug, fn)
{
	var METHOD_NAME = "CreateBannerAdvert";
	debug = debug ? "true" : "false";
	var args = [id, size, debug];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.ShowBannerAdvert = function ShowBannerAdvert (fn)
{
	var METHOD_NAME = "ShowBannerAdvert";
	var args = [];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.HideBannerAdvert = function HideBannerAdvert (fn)
{
	var METHOD_NAME = "HideBannerAdvert";
	var args = [];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.CreateInterstitialAdvert = function CreateInterstitialAdvert (id, debug, fn)
{
	var METHOD_NAME = "CreateInterstitialAdvert";
	debug = debug ? "true" : "false";
	var args = [id, debug];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.ShowInterstitialAdvert = function ShowInterstitialAdvert (fn)
{
	var METHOD_NAME = "ShowInterstitialAdvert";
	var args = [];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.CreateVideoAdvert = function CreateVideoAdvert (id, debug, fn)
{
	var METHOD_NAME = "CreateVideoAdvert";
	debug = debug ? "true" : "false";
	var args = [id, debug];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.ShowVideoAdvert = function ShowVideoAdvert (fn)
{
	var METHOD_NAME = "ShowVideoAdvert";
	var args = [];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.Configure = function Configure (id, pubID, privacyPolicy, showFree, showConsent, debug, debugLocation, fn)
{
	
	var METHOD_NAME = "Configure";

	showFree = showFree ? "true" : "false";
	debug = debug ? "true" : "false";

	var args = [id, pubID, privacyPolicy, showFree, showConsent, debug, debugLocation];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.SetUserPersonalisation = function SetUserPersonalisation (mode, fn)
{
	var METHOD_NAME = "SetUserPersonalisation";
	var args = [mode];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}

exports.RequestConsent = function RequestConsent (fn)
{
	var METHOD_NAME = "RequestConsent";
	var args = [];
	function resolve (str)
	{
		fn(null, str);
	}
	function reject (str)
	{
		fn(str, null);
	}
	exec(resolve, reject, CLASS_NAME, METHOD_NAME, args);
}