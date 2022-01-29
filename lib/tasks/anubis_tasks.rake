namespace :anoubis do
  desc "Prepare Anoubis test database"
  task :prepare do
    Rake::Task['app:db:migrate'].invoke
    Rake::Task['app:db:test:prepare'].invoke
    Rake::Task['app:db:seed'].invoke
  end
end


