[![Build Status](https://travis-ci.org/pivotal/whiteboard.png?branch=master)](https://travis-ci.org/pivotal/whiteboard)
[![Code Climate](https://codeclimate.com/github/pivotal/whiteboard.png)](https://codeclimate.com/github/pivotal/whiteboard)

Goals
=====
Whiteboard is an app which aims to increase the effectiveness of office-wide standups, and increase communication with the technical community by sharing what we learn with the outside world.  It does this by making two things easy - emailing a summary of the standup to everyone in the company and by creating a blog post of the items which are deemed of public interest.

Background
==========
At Pivotal Labs we have an office-wide standup every morning at 9:06 (right after breakfast). The current format is new faces (who's new in the office), helps (things people are stuck on) and interestings (things that might be of interest to the office).

Before Whiteboard, one person madly scribbled notes, and one person ran standup using a physical whiteboard as a guide to things people wanted to remember to talk about.  Whiteboard provides an easy interface for people to add items they want to talk about, and then a way to take those items and assemble them into a blog post and an email with as little effort as possible.  The idea is to shift the writing to the person who knows about the item, and reduce the role of the person running standup to an editor.

Features
========
- Add New Faces, Helps and Interesting
- Summarize into posts
- Two click email sending (the second click is for safety)
- Two click Posts to Wordpress (untransformed markdown at the moment)
- Allow authorized IP addresses to access boards without restriction
- Allows users to sign in using Okta if their IP is not Whitelisted

Usage
=====
Deploy to Cloud Foundry.  Tell people in the office to use it.  At standup, go over the board, then add a title and click 'create post'.  The board is then cleared for the next day, and you can edit the post at your leisure and deliver it when ready.

Development
===========
Whiteboard is a Rails 4 app. It uses rspec with capybara for request specs.  Please add tests if you are adding code.

Whiteboard feature tests are incompatible with Qt 5.5, ensure you have a lower version installed before running `bundle`

Whiteboard [is on Pivotal Tracker](https://www.pivotaltracker.com/projects/560741).

The following environment variables are necessary for posting to a Wordpress blog.
```
export WORDPRESS_BLOG_HOST=<blog server>
export WORDPRESS_BASIC_AUTH_USER=<user> #optional
export WORDPRESS_BASIC_AUTH_PASSWORD=<password> #optional
export WORDPRESS_XMLRPC_ENDPOINT_PATH=/wordpress/xmlrpc.php
export WORDPRESS_USER=<username>
export WORDPRESS_PASSWORD=<password>
```
The following environment variables are necessary for posting to email via SendGrid.
```
export SENDGRID_USERNAME=<username>
export SENDGRID_PASSWORD=<password>
```
Okta needs to be configured for SAML 2.0 before you can set up Okta single sign-on. Check out [Okta's](http://developer.okta.com/docs/guides/setting_up_a_saml_application_in_okta.html) documentation
for more information.

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

Testing
=======
Before running tests, make sure to add your local IP to the IP_WHITELIST environment variable string. Then run

```
bundle exec rspec
```

# How to Deploy to Cloud Foundry

##First Time Deployment Setup

    cf target --url https://api.run.pivotal.io
    cf login
    cf target -s whiteboard -o <organization>

	cf push --no-start --reset
	cf set-env whiteboard-production WORDPRESS_USER username
	cf set-env whiteboard-production WORDPRESS_PASSWORD password
	cf set-env whiteboard-production WORDPRESS_BLOG_HOST blogname.wordpress.com
	cf set-env whiteboard-production WORDPRESS_XMLRPC_ENDPOINT_PATH /wordpress/xmlrpc.php
	cf set-env whiteboard-production EXCEPTIONAL_API_KEY <you exceptional API key>
    cf set-env whiteboard-acceptance WORDPRESS_USER username
    cf set-env whiteboard-acceptance WORDPRESS_PASSWORD password
    cf set-env whiteboard-acceptance WORDPRESS_BLOG_HOST blogname.wordpress.com
    cf set-env whiteboard-acceptance WORDPRESS_BASIC_AUTH_USER <user>
    cf set-env whiteboard-acceptance WORDPRESS_BASIC_AUTH_PASSWORD <password>
    cf set-env whiteboard-acceptance WORDPRESS_XMLRPC_ENDPOINT_PATH /wordpress/xmlrpc.php
    cf set-env whiteboard-acceptance EXCEPTIONAL_API_KEY <your exceptional API key>
	cf env   # check all settings
	# migrate data
	cf push --reset  # push env settings and start app
	cf start


##Deployment After ENV Vars Set

First, log into Cloud Foundry:

    cf target --url https://api.run.pivotal.io
    cf login

Then run:

    rake acceptance deploy

or

    rake production deploy

The rake task copies the code to be deployed into a `/tmp` directory, so you can continue working while deploying.

Author
======
Whiteboard was written by [Matthew Kocher](https://github.com/mkocher).

License
=======
Whiteboard is MIT Licensed. See MIT-LICENSE for details.
