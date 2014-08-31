# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "oauth"
require "json"

# Poll CubeSensors for the given keys.
#
class LogStash::Inputs::Clip < LogStash::Inputs::Base
  
  config_name "clip"
  
  milestone 1

  # Set this to true to enable debugging on an input.
  config :debug, :validate => :boolean, :default => false

  # Key
  config :consumer_key, :validate => :string, :required => true
  
  # Secret
  config :consumer_secret, :validate => :string, :required => true
  
  # Token
  config :token, :validate => :string, :required => true
  
  # Token Secret
  config :token_secret, :validate => :string, :required => true

  # Interval to run the command. Value is in seconds.
  config :interval, :validate => :number, :required => true

  CS_API = "https://api.cubesensors.com"

  public
  def register
    @logger.info("Registering Cbsr Input", :type => @type,
                 :consumer_key => @consumer_key, :interval => @interval)
                 
    # Here would go the Oauth stuff...
    
  end # def register

  public
  def run(queue)

    loop do
      start = Time.now
      @logger.info? && @logger.info("Polling CBSR", :consumer_key => @consumer_key)  
      #GET data
      
      
      # The consumer key and consumer secret are the identifiers for this particular application, and are 
      # issued when the application is registered with the site. Use your own.
      @consumer=OAuth::Consumer.new consumer_key, 
                              consumer_secret, {
							  :site => CS_API,
							  :scheme => :query_string, 
							  :request_token_path => "/auth/request_token",
							  :access_token_path  => "/auth/access_token",
							  :authorize_path => "/auth/authorize"
							  }
							
      #this lets you see raw wire calls
      if @debug
         @consumer.http.set_debug_output($stdout)
      end

      # Create the access_token for all traffic
      @access_token = OAuth::AccessToken.new(@consumer, token, token_secret) 

      # Use the access token for various commands. Although these take plain strings, other API methods 
      dev = JSON.parse(@access_token.get("/v1/devices/").body)

      if @debug
        puts JSON.pretty_generate(dev)
      end

      dev["devices"].each do |device|
    	cubeCur = JSON.parse(@access_token.get("/v1/devices/" + device["uid"] + "/current").body)
    	
    	# get all data for the current device
    	if @debug
		  puts "Cube: " + device["extra"]["name"] + "(" + device["uid"] + ")"
        end
      	    
      	# create an event
      	event = LogStash::Event.new(
            "source" => CS_API + "/v1/devices/" + device["uid"] + "/current",
            "cubeId" => device["uid"],
            "cubeName" => device["extra"]["name"]
        )
                
      	cubeCur["field_list"].each_index do |i|
          if @debug
            puts "    " + cubeCur["field_list"][i] + ": " + cubeCur["results"][0][i].to_s
       	  end
       	  
       	  event[cubeCur["field_list"][i]] = cubeCur["results"][0][i]
       	  
        end # device loop
        
        # put the event to the queue
        decorate(event)
        queue << event
        
      end # device loop

      duration = Time.now - start
      @logger.info? && @logger.info("Polling CBSR completed", :consumer_key => @consumer_key, :duration => duration)

      # Sleep for the remainder of the interval, or 0 if the duration ran
      # longer than the interval.
      sleeptime = [0, @interval - duration].max
      if sleeptime == 0
        @logger.warn("Polling CBSR ran longer than the interval. Skipping sleep.",
                     :consumer_key => @consumer_key, :duration => duration,
                     :interval => @interval)
      else
        sleep(sleeptime)
      end
    end # loop
    
  end # def run
  
end # class LogStash::Inputs::Clip
