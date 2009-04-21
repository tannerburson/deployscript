#!/usr/bin/ruby -rubygems
$:.unshift(File.join( File.dirname(__FILE__), '..', 'lib'))
require 'deploy'

# This portion could be in an external config file
Deploy::app :name do
	@app_path = '/home/tanner/apps/sample' # cd to this directory before anything else
	@repo_url = 'git@github.com:tannerburson/some-sample.git'
	@remote_server = 'example.com'
	@env = "development"
end

# This is the actual deployment recipe, tied to the above configuration by name
# you could have several recipes in separate files depending on the situation
deploying :name do
	update ['rm -rf backup',
			'cp -R release backup',
			'rm -rf release',
			"git clone #{@repo_url} release",
			"cd #{@app_path}/release/app ",
			"rake db:upgrade"]
	start  "cd release/app && thin -e #{@env} -C config.yml start"
	# Any command can be an array of shell commands to run
	stop   "thin -C #{@app_path}/release/app/config.yml stop"
	# deploy automatically calls update, start, stop if they've been specified
	deploy 
end
