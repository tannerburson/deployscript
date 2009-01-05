module Deploy
	class App 

		def initialize( appname )
			@name = appname
			@commands = {}
			@verbose = false
			@app_path = ''
		end

		def setup
			if @remote_server
				require 'net/ssh'
				@exec = Net::SSH.start(@remote_server, @remote_user)
			else
				@exec = Kernel
			end
			self
		end

		def update( cmd = '')
			command(:update,cmd)
		end

		def start( cmd = '')
			command(:start,cmd)
		end

		def stop( cmd = '')
			command(:stop,cmd)
		end

		def deploy( cmd = '' )
			@commands[:deploy] = cmd unless cmd.empty?
			run_command update
			run_command stop
			run_command start
			run_command cmd unless cmd.empty?
			@exec.close if @exec.respond_to? :close
		end

		protected
		def run_command(command)
			case command
			when Array
				puts "DEPLOY: executing " << command.join(" && ") if @verbose
				cmd = command.join(" && ")
				cmd = "cd " << @app_path << " && " << cmd unless @app_path.empty?
				retval = deploy_exec(cmd)
			when String	
				puts "DEPLOY: executing " << command if @verbose
				cmd = command
				cmd = "cd " << @app_path << " && " << cmd unless @app_path.empty?
				retval = deploy_exec(cmd)
			end
		end

		def command(name,cmd)
			@commands[name] = cmd unless cmd.empty?
			@commands[name]
		end

		def deploy_exec(command)
			@exec.exec!(command)
		end
	end

	@@apps = {}

	def self.app(appname, &params)
		@@apps[appname] = App.new(appname) unless @@apps[appname]
		@@apps[appname].instance_eval(&params) if block_given?
		@@apps[appname].setup
	end

end
## Global Scope, ugh
def deploying (appname, &script) 
	Deploy.app(appname).instance_eval(&script)
end

## So we can cheat when dealing with SSH
module Kernel
	def exec!(command)
		system(command)
	end
end
