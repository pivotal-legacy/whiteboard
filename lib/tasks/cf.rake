require 'fileutils'

ENVIRONMENT = nil

desc 'Set deployment configuration for acceptance'
task :acceptance do
  ENVIRONMENT = 'acceptance'
end

desc 'Set deployment configuration for production'
task :production do
  ENVIRONMENT = 'production'
end

desc 'Set deployment configuration for cso-production'
task :'cso-production' do
  ENVIRONMENT = 'cso-production'
end

desc 'Deploy on Cloud Foundry'
task :deploy => 'cf:deploy'

desc 'Deploy both the standard production app and the CSO production app'
task :deploy_all_production do
  Rake::Task['cso-production'].invoke
  Rake::Task['deploy'].invoke

  Rake::Task['deploy'].reenable

  Rake::Task['production'].invoke
  Rake::Task['deploy'].invoke
end

namespace :cf do
  task :deploy do
    raise 'Specify `rake acceptance deploy`, or `rake production deploy`' unless ENVIRONMENT

    environment = ENVIRONMENT
    cf_target = 'api.run.pivotal.io'
    deploy_space = 'whiteboard'
    deploy_org = "pivotallabs"

    check_for_cli
    check_for_dirty_git
    tag_deploy(environment)

    sh "cf api #{cf_target}"
    sh "cf target -o #{deploy_org} -s #{deploy_space}"
    sh "cf push -f config/cf-#{environment}.yml"
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
