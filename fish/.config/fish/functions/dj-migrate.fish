function dj-migrate --wraps='./manage.py makemigrations && ./manage.py migrate' --description 'alias dj-migrate=./manage.py makemigrations && ./manage.py migrate'
    ./manage.py makemigrations && ./manage.py migrate $argv
end
