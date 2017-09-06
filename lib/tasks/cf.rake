require 'fileutils'

ENVIRONMENT = nil
SPACE = nil

desc 'Set deployment configuration for acceptance'
task :acceptance do
  ENVIRONMENT = 'acceptance'
  SPACE = 'whiteboard-staging'
end

desc 'Set deployment configuration for production'
task :production do
  ENVIRONMENT = 'production'
  SPACE = 'whiteboard-production'
end

desc 'Set deployment configuration for cso-production'
task :'cso-production' do
  ENVIRONMENT = 'cso-production'
  SPACE = 'whiteboard-cso'
end

desc 'Deploy on Cloud Foundry'
task :deploy => 'cf:deploy'

desc 'Deploy both the standard production app and the CSO production app'
task :deploy_all_production do
  puts 'Deploying CSO production...'
  Rake::Task['cso-production'].invoke
  Rake::Task['cf:deploy'].invoke
  puts 'Done!'

  Rake::Task['cf:deploy'].reenable

  puts 'Deploying Labs production...'
  Rake::Task['production'].invoke
  Rake::Task['cf:deploy'].invoke
  puts 'Done!'
end

namespace :cf do
  task :deploy do
    raise 'Specify `rake acceptance deploy`, or `rake production deploy`' unless (ENVIRONMENT && SPACE)

    environment = ENVIRONMENT

    check_for_cli
    check_for_dirty_git
    tag_deploy(environment)
  end

  def check_for_cli
    unless is_go_cli?
      raise "The CloudFoundry CLI is required. Run: 'brew tap pivotal/tap && brew install cloudfoundry-cli'"
    end
  end

  def check_for_dirty_git
    raise "Unstaged or uncommitted changes cannot be deployed! Aborting!" if `git status --porcelain`.present?
  end

  def tag_deploy env
    sh "autotag create #{env}"
  end

  def is_go_cli?
    `cf -v`.match(/version (\d\.\d)/)
    $1.to_f >= 6
  end
end
