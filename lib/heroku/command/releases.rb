require 'vendor/heroku/okjson'

require_relative './remote_command'

class Heroku::Command::Releases
  include Heroku::Command::RemoteCommand

  @@rollback_method = Heroku::Command::Releases.instance_method(:rollback)

  def rollback
    @@rollback_method.bind(self).call
    release = Heroku::OkJson.decode(heroku.get('/apps/' + app + '/releases/current'))
    Heroku::Command::Repo.new.run_remote('update-ref', sha1: release['commit'])
  end
end
