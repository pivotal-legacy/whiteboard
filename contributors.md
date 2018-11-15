# URLs
Staging can be found at [https://whiteboard-staging.cfapps.io](https://whiteboard-staging.cfapps.io) 
Prod for Pivotal in general is at [https://whiteboard.pivotal.io](https://whiteboard.pivotal.io) and for CSO it is at [https://account-standups.cfapps.io/](https://account-standups.cfapps.io/)

# Services
[CodeClimate](https://codeclimate.com/)

## SendGrid
We use [SendGrid](http://sendgrid.com) to send Whiteboard summary emails. Sendgrid Rails documentation can be found
[here.](https://sendgrid.com/docs/Integrate/Frameworks/rubyonrails.html)

## Optional Logging
We use [Papertrail](http://papertrail.com) to save our logs. Documentation for setting Papertrail up is found 
[here.](http://docs.run.pivotal.io/devguide/services/log-management-thirdparty-svc.html#papertrail)

##Okta
### Okta Setup
1. Things you need
1. Setup
1. Issues we encountered
##### Things you need to configure Okta
- Admin access to Okta
- Single sign on URL: The URL where authentication responses (containing assertions) are returned. This will be something like http://host.com/auth/saml/callback
- OKTA_SSO_TARGET_URL: The Okta endpoint that accepts authentication requests. This is provided by Okta.
- OKTA_CERT_FINGERPRINT: A certificate used to validate the signature of the authentication response from Okta. This certificate is provided by Okta, but you will have to fingerprint it.
##### Setup
To set up your Okta app, follow the instructions in the README.md __Make sure you do not uncheck the box that says 'Use this for Recipient URL and Destination URL' despite the instructions on this link.__

##### Issues we encountered
1. You must provide a full filepath to `openssl x509 -noout -fingerprint -in "/full/file/path"`
1. You must __not__ uncheck 'Use this for Recipient URL and Destination URL'
