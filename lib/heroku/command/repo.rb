require 'base64'
require 'em-eventsource'
require 'erb'
require 'vendor/heroku/okjson'

# Slug manipulation
class Heroku::Command::Repo < Heroku::Command::BaseWithApp

  # repo:purge_cache
  #
  # Deletes the contents the build cache in the repository
  #
  def purge_cache
    run_remote 'purge_cache'
  end

  # repo:gc
  #
  # Run a git gc --agressive on the applications repository
  #
  def gc
    run_remote 'gc'
  end

  # repo:download
  #
  # Download the repository
  def download
    puts repo_get_url
    system("curl -o #{app}-repo.tgz '#{repo_get_url}'")
  end

  # repo:reset
  #
  # Reset the repo and cache
  def reset
    run_remote 'reset'
  end

  # repo:rebuild
  #
  # Force a rebuild of the master branch
  def rebuild
    reset
    system "git push #{extract_app_from_git_config || "heroku"} master"
  end

  private

  def release
    @release ||= Heroku::OkJson.decode(heroku.get('/apps/' + app + '/releases/new'))
  end

  def repo_get_url
    release['repo_get_url']
  end

  def repo_put_url
    release['repo_put_url']
  end

  def run_remote(command)
    EM.run do
      source_url = "https://heroku-repo-backend.herokuapp.com/commands/#{command}?app=#{app}"

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
