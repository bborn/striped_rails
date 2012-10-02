redis: redis-server 
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: ./start_resque
guard: bundle exec guard
log: tail -f -n 0 ./log/development.log