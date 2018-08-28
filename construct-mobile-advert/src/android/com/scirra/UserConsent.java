package com.scirra;

import android.content.Context;

import com.google.ads.consent.ConsentForm;
import com.google.ads.consent.ConsentFormListener;
import com.google.ads.consent.ConsentInfoUpdateListener;
import com.google.ads.consent.ConsentInformation;
import com.google.ads.consent.ConsentStatus;
import com.google.ads.consent.DebugGeography;

import org.apache.cordova.CallbackContext;

import java.net.MalformedURLException;
import java.net.URL;

public class UserConsent {
    public ConsentStatus status = ConsentStatus.UNKNOWN;
    private String privacyURL = null;
    private Boolean allowFreeOption = null;
    private ConsentForm form = null;
    private CallbackContext callbackContext;

    void UpdateUserConsent(String pubID, Context context, Boolean displayFreeOption, String showConsent, String privacyURLString, String deviceID, String debugLocation, CallbackContext callback)
    {
        callbackContext = callback;
        privacyURL = privacyURLString;
        allowFreeOption = displayFreeOption;

        if (showConsent.equals("never"))
        {
            callbackContext.success("UNKNOWN");
            return;
        }

        Boolean showEverywhere = showConsent.equals("always");
        ConsentInformation consentInformation = ConsentInformation.getInstance(context);

        if (deviceID != null)
        {
            consentInformation.addTestDevice(deviceID);

            if (debugLocation.equals("EEA"))
                consentInformation.setDebugGeography(DebugGeography.DEBUG_GEOGRAPHY_EEA);
            else if (debugLocation.equals("NOT_EEA"))
                consentInformation.setDebugGeography(DebugGeography.DEBUG_GEOGRAPHY_NOT_EEA);
        }

        String[] publisherIds = { pubID };
        consentInformation.requestConsentInfoUpdate(publisherIds, new ConsentInfoUpdateListener() {
            @Override
            public void onConsentInfoUpdated(ConsentStatus consentStatus) {
                status = consentStatus;

                Boolean inEEA = ConsentInformation.getInstance(context).isRequestLocationInEeaOrUnknown();

                // if the user is outside of the EEA then consent is not required
                if (showEverywhere == false && inEEA == false)
                    status = ConsentStatus.PERSONALIZED;

                if (status == ConsentStatus.PERSONALIZED)
                    callbackContext.success("PERSONALIZED");
                else if (status == ConsentStatus.NON_PERSONALIZED)
                    callbackContext.success("NON_PERSONALIZED");
                else
                    ShowUserConsentForm(callbackContext, context);
            }

            @Override
            public void onFailedToUpdateConsentInfo(String errorDescription) {
                status = ConsentStatus.UNKNOWN;
                callbackContext.error(errorDescription);
            }
        });
    }

    void SetStatus (String status, CallbackContext callbackContext)
    {
        if (status.equals("PERSONALIZED"))
        {
            this.status = ConsentStatus.PERSONALIZED;
        }
        else if (status.equals("NON_PERSONALIZED"))
        {
            this.status = ConsentStatus.NON_PERSONALIZED;
        }
        else if (status.equals("AD_FREE") || status.equals("UNKNOWN"))
        {
            this.status = ConsentStatus.UNKNOWN;
            callbackContext.success("UNKNOWN");
            return;
        }
        else
        {
            this.status = ConsentStatus.UNKNOWN;
            callbackContext.error("invalid status type");
            return;
        }
        
        callbackContext.success(status);
    }

    private void CreateUserConsentForm(Context context)
    {
        URL url = null;

        try
        {
            url = new URL(privacyURL);
        }
        catch (MalformedURLException e)
        {
            callbackContext.error("Invalid privacy URL");
            return;
        }

        ConsentForm.Builder builder = new ConsentForm.Builder(context, url)
            .withListener(new ConsentFormListener()
            {
                @Override
                public void onConsentFormLoaded()
                {
                    if (form != null)
                        form.show();
                }

                @Override
                public void onConsentFormOpened()
                {
                    // Consent form was displayed. ( don't really care )
                }

                @Override
                public void onConsentFormClosed(ConsentStatus consentStatus, Boolean userPrefersAdFree)
                {
                    status = consentStatus;

                    if (status == ConsentStatus.PERSONALIZED)
                        callbackContext.success("PERSONALIZED");
                    else if (status == ConsentStatus.NON_PERSONALIZED)
                        callbackContext.success("NON_PERSONALIZED");
                    else if (userPrefersAdFree)
                        callbackContext.success("UNKNOWN");
                    else
                        callbackContext.success("UNKNOWN");

		    form = null;
                }

                @Override
                public void onConsentFormError(String errorDescription)
                {
                    callbackContext.error(errorDescription);
                }
            })
            .withPersonalizedAdsOption()
            .withNonPersonalizedAdsOption();

        if (allowFreeOption)
            builder.withAdFreeOption();

        form = builder.build();

        form.load();
    }

    void ShowUserConsentForm(CallbackContext callback, Context context)
    {
        if (privacyURL == null) {
            callbackContext.error("User consent unconfigured");
            return;
        }

        callbackContext = callback;

        CreateUserConsentForm(context);
    }
}