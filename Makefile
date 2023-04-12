install:
	bundle install

console:
	bin/console

tests:
	bundle exec rake spec

lint:
	bundle exec rubocop .

fix:
	bundle exec rubocop -a .

fix!:
	bundle exec rubocop -A .

reek:
	bundle exec reek .

full-check:
	@make lint
	@make reek
	@make tests