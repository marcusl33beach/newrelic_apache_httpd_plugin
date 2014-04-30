newrelic_apache_httpd_plugin
===============================

New Relic Plugin for Apache HTTPD

### Instructions for running the plugin

1. Enable mod_status on your Apache HTTPD server: http://bit.ly/14kiUGI
2. Go to: https://github.com/newrelic-platform/newrelic_apache_httpd_plugin.git
3. Download and extract the source to a local directory
4. Run `bundle install` in the directory with this source
5. Copy `config/template_newrelic_plugin.yml` to `config/newrelic_plugin.yml`
6. Edit `config/newrelic_plugin.yml` and replace:
	* `'YOUR_LICENSE_KEY_HERE'` with your New Relic license key (in ' ')
	* `httpd.apache.org` with the hostname of your Apache HTTPD server
7. Execute `./newrelic_apache_httpd_plugin.rb`
8. Go back to the Plugins list, after a brief period you will see an entry called `HTTPD`

#### Notes / Tips

* Ensure that the server-status page (http://[hostname]/server-status) is reachable from where you are running this extension.
* If not accessible, check the security settings for mod_status. It can restrict users with authentication or by IP.
* The current version of this extension does not support authentication with mod_status.
* Set "debug: true" in newrelic_plugin.yml to see the metrics logged to stdout instead of sending them to New Relic.
