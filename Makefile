install:
	bundle install

console:
	bin/console

tests:
	bundle exec rake test

lint:
	bundle exec rubocop .

fix:
	bundle exec rubocop -a .

fix!:
	bundle exec rubocop -A .

smells-check:
	bundle exec reek .