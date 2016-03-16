# URLs
Staging can be found at [whiteboard-acceptance.cfapps.io](https://whiteboard-acceptance.cfapps.io)
Prod is either [whiteboard-production.cfapps.io](https://whiteboard-production.cfapps.io) or [whiteboard.pivotallabs.com](http://whiteboard.pivotallabs.com)
For CI, we use [Travis](https://travis-ci.org/pivotal/whiteboard).

# How to Deploy
We use [Evaporator](https://github.com/pivotal/evaporator) to deploy Whiteboard.
Following Evaporator convention, there's `config/cf-staging.yml` that provides configuration for the `cf:deploy:staging` command. 
To deploy to staging, authenticate with PWS via cf-cli, and run `SPACE=whiteboard bundle exec rake cf:deploy:staging`

# Services
[CodeClimate](https://codeclimate.com/)

## SendGrid
We use [SendGrid](http://sendgrid.com) to send Whiteboard summary emails. Sendgrid Rails documentation can be found
[here.](https://sendgrid.com/docs/Integrate/Frameworks/rubyonrails.html)

## Wordpress
Whiteboard uses Wordpress integration to post standup summaries to the Pivotal Labs blog. Information on setting up the
Wordpress environment variables can be found in the [readme](./README.md).

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
