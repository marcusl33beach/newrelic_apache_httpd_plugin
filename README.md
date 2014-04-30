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

### **IMPORANT** - If you want to use the Remote JMX plugin:

* **You MUST set `pluginname="your.arbitrary.name.here"` in `application.conf`, in order to setup custom dashboards and summary metrics. _If you leave the default, then it will appear with a default dashboard, which can't be edited and won't be presenting your JMX counters._**
* Once you set your own plugin name and it reports in as a new plugin, you'll need to create dashboards and summary metrics to expose your JMX counters. The New Relic Docs offer the best explanation of these capabilities:
  - https://docs.newrelic.com/docs/plugin-dev/changing-plugin-settings
  - https://docs.newrelic.com/docs/plugin-dev/creating-summary-metrics-for-plugins
  - https://docs.newrelic.com/docs/plugin-dev/working-with-plugin-dashboards
* The `host`, `port` and `name` (instance name to appear in New Relic UI) are also required for each instance.
* Wildcards ARE permissable in an Object Name, for example: `java.lang:type=GarbageCollector,name=*`
* Multiple Attributes ARE permissable under an Object Name, for example: `["CollectionCount", "CollectionTime"]`
* If polling a single Attribute in an Object Name, you will still need to put it inside of '[' and ']', like so: `["CollectionCount"]`
* `type` is optional. If used, all of the attributes in that ObjectName definition will be typed with what you define here.
* If `type` is not used, the default "value" will be used for the attribute values in that Object Name.
