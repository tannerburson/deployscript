require 'rubygems'
require 'lib/deploy.rb'

# This portion could be in an external config file
Deploy::app :name do
	@verbose = true
	@app_path = '~/tmp' # cd to this directory before anything else
	@remote_server = 'tannerburson.com'
	@remote_user = 'tanner'
end

# This is the actual deployment recipe, tied to the above configuration by name
# you could have several recipes in separate files depending on the situation
deploying :name do
	# update 'git pull' # uncomment to run an update
	start  'echo START CALLED'
	# Any command can be an array of shell commands to run
	stop   ['echo STOP1 CALLED', 
			'echo STOP2 CALLED']
	# deploy automatically calls update, start, stop if they've been specified
	deploy 'echo "Hello" > deploy_test.txt' #add a post deploy command
end
