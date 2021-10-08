#!/bin/sh -ex
./initialVschemaSetup.sh
python manage.py makemigrations && python manage.py migrate && python manage.py  test -v 3 --keepdb