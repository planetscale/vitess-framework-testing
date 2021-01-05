#!/bin/sh -ex

rake db:migrate;
rake db:seed;
rake user:create;
rake user:list;
rake 'user:get[1]';
rake user:delete_first;
rake user:list | head;

