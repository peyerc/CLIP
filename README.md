# CLIP - CubeSensors Logstash Input Plugin

[![CLIP - Kibana](https://raw.githubusercontent.com/peyerc/CLIP/master/clip_kibana.png)](https://raw.githubusercontent.com/peyerc/CLIP/master/clip_kibana.png)

CLIP is an input plugin for Logstash which collects cube data from your
CubeSensors account.

To configure CLIP you need first to get the OAuth credentials for your
CubeSensors account.

## Dependencies

CLIP is using the OAuth gem: https://rubygems.org/gems/oauth

## Configuration

**debug**
If set to true CLIP is logging debug output.
 
**consumer_key**
The OAuth consumer key.

**consumer_secret**
The OAuth consumer secret.

**token**
The OAuth app token.

**token_secret**
The OAuth app token secret.

**interval**
The poll interval in second.

### Input filter configuration example
	input {
		clip {
			debug => false
			consumer_key => "abc123"
			consumer_secret => "acacacacac12121212"
			token => "aabbB34ccc"
			token_secret => "aB12fb"
			interval => 60
		}
	}

    date {
    	match => [ "time", "ISO8601" ]
    }
