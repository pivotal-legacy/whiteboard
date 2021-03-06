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

There is also a more detailed [Whiteboard "How To" page](https://sites.google.com/pivotal.io/ips/products/whiteboard) explaining the UI and common workflows on the [Pivotal Internal Products and Services website](https://sites.google.com/pivotal.io/ips/home). The app is not under active development, but you can log bugs and give feedback by emailing ask@pivotal.io.

Tracker
=======
Whiteboard [is on Pivotal Tracker](https://www.pivotaltracker.com/projects/560741).


Development
===========
Whiteboard is a Rails 4 app. It uses rspec with capybara for request specs.  Please add tests if you are adding code.

Whiteboard feature tests are **incompatible** with Qt 5.5, ensure you have a lower version installed before running `bundle`.

#### Dependencies

- Ruby 2.6.2
- MySQL 5.7.x (later versions don't seem to work)
- Qt 4ish(for capybara-webkit)

#### Qt installation on macOS:

We use an old version of QT because the version of capybara-webkit that is used in test requires < version 5. To install:
1. Add tap from: https://github.com/cartr/homebrew-qt4
   ```
   brew tap cartr/qt4
   brew tap-pin cartr/qt4
   brew install qt@4 qt-webkit@2.3
   brew link qt@4
   ```

#### Qt installation on Linux:
1. apt-get -yq --no-install-suggests --no-install-recommends --force-yes install libqtwebkit-dev libqtwebkit4


### Application Setup:
```
# Install gems
gem install bundler
LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/ bundle install # mysql2 needs the LIBRARY_PATH

# Setup dev/test databases
bundle exec rake db:create db:migrate db:test:prepare

# Run the specs
bundle exec rake
```

Commons Problems:
- `ld: library not found for -lssl` during the `bundle install` step. 
  Solution: Make sure OpenSSL is installed and added to your `LIBRARY_PATH`:
  ```
  brew install openssl
  export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/
  ```
- `Mysql2::Error: Can't connect to local MySQL server through socket '/tmp/mysql.sock'(2)`.
  Solution: Start the local MySQL server
  ```
  mysql.server start
  ```

### Running Locally:

Whiteboard uses unicorn as the server in staging and production. To run the application locally:

    bundle exec unicorn

### Sendgrid environment variables
The following environment variables are necessary for posting to email via SendGrid.
```
export SENDGRID_USERNAME=<username>
export SENDGRID_PASSWORD=<password>
```

### Okta configuration (Deprecated)

**Whiteboard now authenticates with VMware Workspace ONE, however you can still use SAML 2.0 authentication by just providing the URL for the IDP metadata in the environment variable `IDP_METADATA_XML_URL`.

You will also need to configure the Audience by setting the `WS1_AUDIENCE` environment variable** 

Okta needs to be configured for SAML 2.0 before you can set up Okta single sign-on. Check out [Okta's](http://developer.okta.com/docs/guides/setting_up_a_saml_application_in_okta.html) documentation
for more information. [The information below appears to be out of date, but may be helpful -- 11/2018]

There are two environment variables required by Okta. Check LastPass for the .env.development file to use the common localhost Okta preview app.

If you want to grab the variables from Okta preview itself, you can do the following:

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

### IP Whitelisting

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

Also be sure to add a value for `IDP_METADATA_XML_URL` which points to a sample metadata.xml url

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
	cf set-env whiteboard-production
    cf set-env whiteboard-acceptance
	cf env   # check all settings
	# migrate data
	cf push --reset  # push env settings and start app
	cf start


## Deployment After ENV Vars Set

This process is deprecated in favor of letting Concourse deploy via a pipeline. The following commands may still function:

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
There are two pairs of staging/production pipelines, one for general Pivotal use, and one for CSO specifically. Using the pipelines you can deploy the latest on whiteboard master directly from the UI.

Pipeline configuration files are in the concourse folder in this project. There is a secondary repository for the acceptance tests (https://github.com/pivotal/whiteboard-acceptance-tests) that run against a newly deployed whiteboard.

Any changes you make in the pipeline.yml files need to be uploaded to concourse using the set-pipeline command:
```
fly -t jetway set-pipeline -p <PIPELINE-NAME> -c concourse/<PIPELINE-FILE>.yml --load-vars-from <LOCAL-COPY-OF-CREDENTIALS>
```

Credentials for the pipelines live in `Shared-IPS Dev Accounts/Whiteboard` on Lastpass. Download a local copy to a file so you can set the pipeline, but NEVER COMMIT THEM IN THE REPO.
Any changes to helper files will need to be pushed to GitHub for the pipelines to access them.
When you are done modifying the pipelines make sure to push all changes up to GitHub, not just set the pipelines.

# Credential Rotation

Credentials are stored in LastPass in one note per environment (CSO staging and prod, non-CSO staging and prod).
There is no config server, but the Deploy task in the Concourse pipelines manages the "User Provided Environment Variables" credentials in PWS automatically.
This means to get new variable values out to the environments, you need to `set-pipeline` as described in the section above.

* NEWRELIC_LICENSE is the same across many IPS apps across multiple environments, so likely this cannot change.
* OKTA_CERT_FINGERPRINT is managed by the Okta Admins, and thus we do not change.
* SENDGRID_USERNAME and SENDGRID_PASSWORD are provided by the service tile, but it is unclear where these values come from.
* SENTRY_DSN has one DSN for all Whiteboard environments.
* SECRET_KEY_BASE is a value required by Rails to sign/encrypt the session cookie. Rotating it will invalidate all current sessions on the relevant app.

## Rotating SECRET_KEY_BASE

First you'll need to download the pipeline environment variables for each environment you're rotating from LastPass.
They're located in the `Shared-IPS Dev Accounts\Whiteboard` folder. Save them to your local `/tmp` folder. 

You can use the command below to generate a new SECRET_KEY_BASE value while inside the whiteboard directory:
```
rake secret
```
Be sure to generate a unique value for each environment.

Update the `secret-key-base` with the newly-generated value in each pipeline cred file.
Then follow the steps listed in the above [Deploying via Concourse](#deploying-via-concourse) section to deploy the updated SECRET_KEY_BASE to the pipeline & run a build to deploy the changes when ready.
Lastly, be sure to update the secrets in LastPass so the secret-key-base value is up to date.

## Rotating GitHub Deploy Keys

The GitHub deploy key for the `whiteboard-acceptance-tests` repository can also be rotated. Currently we do not rotate the `maintenance-mode` deploy key.

To rotate the deploy key, follow these instructions to generate a new SSH key pair. Make sure not to not enter a passphrase when prompted. https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key.

Next go to the Settings page of the `whiteboard-acceptance-tests` project on GitHub and click on the Deploy Keys link (https://github.com/pivotal/whiteboard-acceptance-tests/settings/keys).
Click "Add deploy key" to create a new deploy key. Include the date (YY-MM format is fine) in the title, paste in the public key you generated into the Key field, and do not allow write access for the key.

You'll need to update the pipeline cred files with the new deploy key. Paste in your private key into the `iad-dev-whiteboard-deploy-key` field for each cred file for each environment (same value for every environment) & follow [Deploying via Concourse](#deploying-via-concourse) to deploy the updated deploy key.

Author
======
Whiteboard was written by [Matthew Kocher](https://github.com/mkocher).

License
=======
Whiteboard is MIT Licensed. See MIT-LICENSE for details.
