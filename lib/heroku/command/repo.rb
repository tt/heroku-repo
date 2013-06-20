require 'vendor/heroku/okjson'

require_relative './remote_command'

# Slug manipulation
class Heroku::Command::Repo < Heroku::Command::BaseWithApp
  include Heroku::Command::RemoteCommand

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
end
