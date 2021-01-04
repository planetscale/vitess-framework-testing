#!/bin/sh -ex

rake db:migrate;
rake db:seed;
rake user:create;

