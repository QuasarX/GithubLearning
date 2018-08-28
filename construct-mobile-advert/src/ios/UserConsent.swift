class UserConsent: NSObject {
    var status = PACConsentStatus.unknown
    var privacyURL: String?
    var allowFreeOption = false
    
    func UpdateUserConsent(deviceID: String, debugLocation: String, pubID: String, displayFreeOption: Bool, privacyURLString: String, promise: CommandPromise, showConsent: String, plugin: CDVPlugin)
    {
        privacyURL = privacyURLString 
        allowFreeOption = displayFreeOption

        if (showConsent == "never")
        {
            promise.resolve(msg: "UNKNOWN")
            return
        }

        let showEverywhere = showConsent == "always"

        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(
            forPublisherIdentifiers: [ pubID ])
            {(_ error: Error?) -> Void in
            if let error = error
            {
                
                self.status = PACConsentStatus.unknown
                promise.reject(msg: error.localizedDescription)
            }
            else
            {
                self.status = PACConsentInformation.sharedInstance.consentStatus

                // if the user is outside of the EEA then consent is not required
                if showEverywhere == false && PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown == false
                {
                    self.status = PACConsentStatus.personalized
                }
                
                if self.status == PACConsentStatus.personalized
                {
                    promise.resolve(msg: "PERSONALIZED")
                }
                else if self.status == PACConsentStatus.nonPersonalized
                {
                    promise.resolve(msg: "NON_PERSONALIZED")
                }
                else
                {
                    self.ShowUserConsentForm(promise: promise, plugin: plugin)
                }
            }
        }
    }

    func SetUserStatus (status: String, promise: CommandPromise)
    {
        if (status == "PERSONALIZED")
        {
            self.status = PACConsentStatus.personalized;
        }
        else if (status == "NON_PERSONALIZED")
        {
            self.status = PACConsentStatus.nonPersonalized;
        }
        else if (status == "AD_FREE" || status == "UNKNOWN")
        {
            self.status = PACConsentStatus.unknown;
            promise.resolve(msg: "UNKNOWN");
            return;
        }
        else
        {
            self.status = PACConsentStatus.unknown;
            promise.reject(msg: "invalid status type");
            return;
        }
        
        promise.resolve(msg: status);
    }

    func SetDebugLocation (deviceID: String, debugLocation: String)
    {
        if (deviceID != "")
        {
            PACConsentInformation.sharedInstance.debugIdentifiers = [ deviceID ]
        
            if ( debugLocation == "EEA")
            {
                PACConsentInformation.sharedInstance.debugGeography = PACDebugGeography.EEA
            }
            else if ( debugLocation == "NOT_EEA")
            {
                PACConsentInformation.sharedInstance.debugGeography = PACDebugGeography.notEEA
            }
        }
    }
    
    func ShowUserConsentForm(promise: CommandPromise, plugin: CDVPlugin)
    {
        let url = URL(string: privacyURL!)

        guard let form = PACConsentForm(applicationPrivacyPolicyURL: url!) else {
            promise.reject(msg: "Invalid privacy URL")
            return
        }
        form.shouldOfferPersonalizedAds = true
        form.shouldOfferNonPersonalizedAds = true
        form.shouldOfferAdFree = allowFreeOption
        form.load { (_ error: Error?) -> Void in

            if let error = error {
                promise.reject(msg: error.localizedDescription)
            } else {
                form.present(from: plugin.viewController) { (error, userPrefersAdFree) in

                    if let error = error {
                        promise.reject(msg: error.localizedDescription)
                    } else if userPrefersAdFree {
                        promise.resolve(msg: "UNKNOWN")
                    } else {
                        // Check the user's consent choice.
                        self.status = PACConsentInformation.sharedInstance.consentStatus

                        if (self.status == PACConsentStatus.personalized)
                        {
                            promise.resolve(msg: "PERSONALIZED")
                        }
                        else if (self.status == PACConsentStatus.nonPersonalized)
                        {
                            promise.resolve(msg: "NON_PERSONALIZED")
                        }
                        else if userPrefersAdFree
                        {
                            promise.resolve(msg: "UNKNOWN")
                        }
                        else
                        {
                            promise.resolve(msg: "UNKNOWN")
                        }
                    }
                }
            }
        }

    }
}
