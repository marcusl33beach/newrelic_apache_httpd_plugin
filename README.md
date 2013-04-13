newrelic_apache_httpd_extension
===============================

New Relic Apache HTTPD Extension

### Instructions for running the Extension

1. Enable mod_status on your apache HTTPD server: http://bit.ly/14kiUGI
2. Go to: https://github.com/newrelic-platform/newrelic_apache_httpd_extension.git
3. Download and extract the source
4. Run `bundle install`
5. Edit `config/newrelic_plugin.yml` and replace "YOUR_LICENSE_KEY_HERE" with your New Relic license key
6. Edit `config/newrelic_plugin.yml` and replace "httpd.apache.org" with the hostname of your Apache HTTPD server
7. Execute `./newrelic_apache_httpd_extension`
8. Go back to the Extensions list, after a brief period you will see an entry for the Apache HTTPD Extension

#### Notes / Tips
* Ensure that the server-status page is reachable from where you are running this extension.
* If not accessible, check the security settings for mod_status. It can restrict users with authentication or by IP.
* The current version of this extension does not support authentication with mod_status.
* Set "debug: true" in newrelic_plugin.yml to see the metrics logged to stdout instead of sending them to New Relic.