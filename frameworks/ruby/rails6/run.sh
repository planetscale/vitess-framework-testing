#!/bin/sh -ex

rake db:migrate;
rake db:seed;
rake user:create;
rake user:list;
rake user:delete_first;
rake user:list | head;

