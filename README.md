[![Code Climate](https://codeclimate.com/github/pivotal/whiteboard.png)](https://codeclimate.com/github/pivotal/whiteboard)

Goals
=====
Whiteboard is an app which aims to increase the effectiveness of office-wide standups by emailing a summary of the standup to everyone in the company.


Background
==========
Most Pivotal locations have an office-wide standup every morning at 9:06 (right after breakfast). The current format is new faces (who's new in the office), helps (things people are stuck on), interestings (things that might be of interest to the office), and events (activities in the office or in the community).

Before Whiteboard, one person madly scribbled notes, and one person ran standup using a physical whiteboard as a guide to things people wanted to remember to talk about.  Whiteboard provides an easy interface for people to add items they want to talk about, and then a way to take those items and assemble them into an email with as little effort as possible.  The idea is to shift the writing to the person who knows about the item, and reduce the role of the person running standup to an editor.


Features
========
- Add New Faces, Helps, Interestings and Events
- Summarize into posts
- Two click email sending (the second click is for safety)
- Allow authorized IP addresses to access boards without restriction
- Allows users to sign in using Okta if their IP is not Whitelisted

Usage
=====
Deploy Whiteboard to Cloud Foundry/Pivotal Web Services or just create a new standup in the [main Pivotal Whiteboard](https://whiteboard.pivotal.io/).  Tell people in the office to use it.  At standup, go over the board, then add a title and click 'Send Email'.  The board is then cleared for the next day, and everyone on the email list will get a copy of the standup items in their inbox.

There is also a more detailed [Whiteboard "How To" page](https://sites.google.com/pivotal.io/ips/products/whiteboard) explaining the UI and common workflows on the [Pivotal Internal Products and Services website](https://sites.google.com/pivotal.io/ips/home). The app is not under active development, but you can log bugs and give feedback by emailing `ask@pivotal.io`.

Tracker
=======
Whiteboard [is on Pivotal Tracker](https://www.pivotaltracker.com/projects/560741). 


Development
===========
Whiteboard is a Rails 4 app. It uses rspec with capybara for request specs.  Please add tests if you are adding code.

Whiteboard feature tests are **incompatible** with Qt 5.5, ensure you have a lower version installed before running `bundle`.

#### MacOS:

We use an old version of QT because the version of capybara-webkit that is used in test requires < version 5. To install:
1. Add tap from: https://github.com/cartr/homebrew-qt4
   ```
   brew tap cartr/qt4
   brew tap-pin cartr/qt4
   brew install qt@4
   ```
1. `brew install qt@4`
1. `brew install qt-webkit@2.3`

MySql version `5.7.x` is used for the database. Ensure you do not have a later version of mysql installed (data files seem to be incompatible)

The project also needs the mysql2 gem to be `0.3.21`, patchlevel may be different but `0.4+` seems to not be picked up by the ActiveRecord database adapter code.
This gem can be annoying to install, you may need to install before the bundle by running the following in your gemset:

```
gem install mysql2 -- --with-cflags=\"-I/usr/local/opt/openssl/include\" --with-ldflags=\"-L/usr/local/opt/openssl/lib\"
```

#### Linux:
1. apt-get -yq --no-install-suggests --no-install-recommends --force-yes install libqtwebkit-dev libqtwebkit4

### Application Setup:
1. Install gems: `bundle install`
1. Setup dev/test databases: `bundle exec rake db:create db:migrate db:test:prepare`
1. Run the specs: `bundle exec rake`

### Running Locally:

Whiteboard uses unicorn as the server in staging and production. To run the application locally:

    bundle exec unicorn

### Sendgrid environment variables
The following environment variables are necessary for posting to email via SendGrid.
```
export SENDGRID_USERNAME=<username>
export SENDGRID_PASSWORD=<password>
```

### Okta configuration
Okta needs to be configured for SAML 2.0 before you can set up Okta single sign-on. Check out [Okta's](http://developer.okta.com/docs/guides/setting_up_a_saml_application_in_okta.html) documentation
for more information. [The information below appears to be out of date, but may be helpful -- 11/2018]

1. In the appropriate Okta instance, go to Admin > Applications
1. Click Add Application
1. Click Create New App
    * NOTE: You can clone an existing app integration from the "Apps you created" section  
1. Choose SAML 2.0
1. Name the app accordingly:
    * Development: "App Name - Development" and "App Name - Staging"
    * Production: "App Name"
1. Click Next  
1. Fill out the required fields on the SAML Settings page
    * Single sign on URL - e.g. https://pivotal-example.cfapps.io/saml/callback
    * Check the "Use this for Recipient URL and Destination URL" check-box.
    * Audience URI: e.g. https://pivotal-example.cfapps.io/
    * Name ID Format: Email Address
    * Default username: Okta username
1. Click Advanced Settings
    * Response: Signed
    * Assertion: Signed
    * Authentication context class: PasswordProtectedTransport
    * Request Compression: Compressed
1. Click Next
    * Are you a customer or partner?: I'm an Okta customer adding an internal app
    * App type: This is an internal app that we have created
1. Click Save

After finish up initial setup, there are two environment variables required by Okta.

1. In the appropriate Okta instance, go to Admin > Applications and click on the name of the App.
1. Click the Sign On tab
1. Under Settings > Sign On Methods, and click View Setup Instructions.
1. Copy down the Identity Provider Single Sign-On URL and save the X.509 Certificate.
1. Export the Identity Provider Single Sign-On URL

    ```
    export OKTA_SSO_TARGET_URL=<URL from Step 5>
    ```
1. Create an Okta signature fingerprint
    ```
    openssl x509 -noout -fingerprint -in "/full/file/path"
    ```
1. Export the signature output 
    ```
    export OKTA_CERT_FINGERPRINT=<signature from step 6>
    ```

A string including all the IPs used by your office is required as an environment variable in order for IP fencing to work.
The format should be a single string of IPs, e.g.
`192.168.0.1`,
or IP ranges in slash notation, e.g.
`64.168.236.220/24`,
separated by a single comma like so: 
```
192.168.1.1,127.0.0.1,10.10.10.10,33.33.33.33/24
```
Export this string:
```
export IP_WHITELIST=<ip_string>
```
Whiteboard is setup by default to whitelist 127.0.0.1 (localhost) by default to allow the tests to pass. This is located
in the .env.test file.

If you are using Sentry for error logging be sure to set the ```SENTRY_DSN``` environment variable to your Sentry DSN


Testing
=======
Before running tests, make sure to add your local ```IP``` to the ```IP_WHITELIST``` environment variable string. Also make sure that a username and password are configured in ```database.yml``` if your ```root``` user password is not the default. 

Then run

```
bundle exec rspec
```

# How to Deploy to Cloud Foundry

## First Time Deployment Setup 

[Concourse is the preferred deployment method. This first time deployment information appears to be out of date but may still be useful -- 11/2018]

    cf target --url https://api.run.pivotal.io
    cf login
    cf target -s whiteboard -o <organization>

	cf push --no-start --reset
	cf set-env whiteboard-production EXCEPTIONAL_API_KEY <your exceptional API key>
    cf set-env whiteboard-acceptance EXCEPTIONAL_API_KEY <your exceptional API key>
	cf env   # check all settings
	# migrate data
	cf push --reset  # push env settings and start app
	cf start


## Deployment After ENV Vars Set

First, log into Cloud Foundry:

    cf target --url https://api.run.pivotal.io
    cf login

Then run:

    rake acceptance deploy

or

    rake production deploy

The rake task copies the code to be deployed into a `/tmp` directory, so you can continue working while deploying.

## Deploying via Concourse

Whiteboard has pipelines set up on the IPS Jetway Concourse instance: https://jetway.pivotal.io/
There are two pairs of staging/production pipelines, one for general Pivotal use, and one for CSO specifically.
Using the pipelines you can deploy the latest on whiteboard master directly from the UI.

Pipeline configuration files are in the concourse folder in this project. There is a secondary repository for the acceptance tests (https://github.com/pivotal/whiteboard-acceptance-tests) that run against a newly deployed whiteboard.

Any changes you make in the pipeline.yml files need to be uploaded to concourse using the set-pipeline command:
```
fly -t jetway set-pipeline -p <PIPELINE-NAME> -c concourse/<PIPELINE-FILE>.yml --load-vars-from <LOCAL-COPY-OF-CREDENTIALS>
```

Credentials for the pipelines live in `Shared-IAD Dev Accounts/Whiteboard` on Lastpass. Download a local copy to a file so you can set the pipeline, but NEVER COMMIT THEM IN THE REPO.
Any changes to helper files will need to be pushed to GitHub for the pipelines to access them. 
When you are done modifying the pipelines make sure to push all changes up to GitHub, not just set the pipelines.

Author
======
Whiteboard was written by [Matthew Kocher](https://github.com/mkocher).

License
=======
Whiteboard is MIT Licensed. See MIT-LICENSE for details.
