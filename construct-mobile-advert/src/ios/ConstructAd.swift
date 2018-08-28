import GoogleMobileAds
import AdSupport

let GMAD_TEST_APPLICATION_ID = 	"ca-app-pub-3940256099942544~1458002511"

@objc(ConstructAd)
class ConstructAd : CDVPlugin
{
	var bannerAD: BannerAdvert?
	var interstitialAD: InterstitialAdvert?
	var videoAD: VideoAdvert?
    var userConsent: UserConsent?
    
    override init() {
    }
    
    func GetDeviceID () -> String
    {
        if (ASIdentifierManager.shared().isAdvertisingTrackingEnabled)
        {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        else
        {
            return ""
        }
    }
    
    func CreateGADRequest(debug: Bool) -> GADRequest
    {
        let request = GADRequest()
     
        if (debug)
        {
            request.testDevices = [ GetDeviceID() ]
        }
        
        if (userConsent?.status == PACConsentStatus.nonPersonalized)
        {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        return request
    }

	@objc(CreateBannerAdvert:)
	func CreateBannerAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		let unitID = command.arguments[0] as? String ?? ""
		let adSize = command.arguments[1] as? String ?? ""
        let debug = command.arguments[2] as? String ?? ""

		if unitID == ""
		{
         promise.reject(msg: "Unit ID not specified")
			return
		}

		if adSize == ""
		{
			promise.reject(msg: "Ad size not specified")
			return
		}
        
        let request = CreateGADRequest(debug: debug == "true")
        
        self.bannerAD = BannerAdvert(request: request, viewController: viewController, prom: promise, id: unitID, adSize: adSize)
	}

	@objc(ShowBannerAdvert:)
	func ShowBannerAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		self.bannerAD?.show(view: viewController.view, prom: promise)
	}

	@objc(HideBannerAdvert:)
	func HideBannerAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		self.bannerAD?.hide(prom: promise)
	}

	@objc(CreateInterstitialAdvert:)
	func CreateInterstitialAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)
		let unitID = command.arguments[0] as? String ?? ""
        let debug = command.arguments[1] as? String ?? ""

		if unitID == ""
		{
			promise.reject(msg: "Unit ID not specified")
			return
		}
        
        let request = CreateGADRequest(debug: debug == "true")
        
        self.interstitialAD = InterstitialAdvert(request: request, prom: promise, id: unitID)
	}

	@objc(ShowInterstitialAdvert:)
	func ShowInterstitialAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		self.interstitialAD?.show(viewController: viewController, prom: promise)
	}

	@objc(CreateVideoAdvert:)
	func CreateVideoAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)
		let unitID = command.arguments[0] as? String ?? ""
        let debug = command.arguments[1] as? String ?? ""

		if unitID == ""
		{
			promise.reject(msg: "Unit ID not specified")
			return
		}
        
        let request = CreateGADRequest(debug: debug == "true")

        self.videoAD = VideoAdvert(request: request, prom: promise, id: unitID)
	}

	@objc(ShowVideoAdvert:)
	func ShowVideoAdvert(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		self.videoAD?.show(viewController: viewController, prom: promise)
	}

	@objc(SetUserPersonalisation:)
	func SetUserPersonalisation(command: CDVInvokedUrlCommand)
	{
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		var status = command.arguments[0] as? String ?? ""

		userConsent?.SetUserStatus(status: status, promise: promise)
	}

	@objc(Configure:)
	func Configure(command: CDVInvokedUrlCommand) {
		let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)

		var id = command.arguments[0] as? String ?? ""
        let pubID = command.arguments[1] as? String ?? ""
        let privacyURL = command.arguments[2] as? String ?? ""
		let displayFree = (command.arguments[3] as? String ?? "") == "true"
        let showConsent = command.arguments[4] as? String ?? ""
        let debug = (command.arguments[5] as? String ?? "") == "true"
        let debugLocation = command.arguments[6] as? String ?? ""
        
		if id == ""
		{
			promise.reject(msg: "Application ID not specified")
			return
		}
        
        if pubID == ""
        {
            promise.reject(msg: "Publisher ID not specified")
            return
        }
        
        if privacyURL == ""
        {
            promise.reject(msg: "Privacy URL not specified")
            return
        }
        
		if debug == true
		{
			id = GMAD_TEST_APPLICATION_ID
		}
        
        let deviceID = debug == true ? GetDeviceID() : ""
        
        GADMobileAds.configure(withApplicationID: id)
        
        userConsent = UserConsent()
        
        userConsent?.UpdateUserConsent(deviceID: deviceID, debugLocation: debugLocation, pubID: pubID, displayFreeOption: displayFree, privacyURLString: privacyURL, promise: promise, showConsent: showConsent, plugin: self)
	}
    
    @objc(RequestConsent:)
    func RequestConsent(command: CDVInvokedUrlCommand)
    {
        let promise = CommandPromise(id: command.callbackId, comDelegate: self.commandDelegate)
        self.userConsent?.ShowUserConsentForm(promise: promise, plugin: self)
    }
}
