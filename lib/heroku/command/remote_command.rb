require 'base64'
require 'em-eventsource'

require_relative '../../hash'

module Heroku::Command::RemoteCommand
  def run_remote(command, params={})
    EM.run do
      params.merge!({ 'app' => app })

      source_url = "https://#{Heroku::Auth.api_key}@heroku-repo-backend.herokuapp.com/commands/#{command}?#{params.to_query_string}"

      source = EventMachine::EventSource.new(source_url)

      source.on 'out' do |message| STDOUT << Base64.decode64(message) end
      source.on 'err' do |message| STDERR << Base64.decode64(message) end

      source.on 'close' do
        source.close
        EM.stop
      end

      source.start
    end
  end
end
