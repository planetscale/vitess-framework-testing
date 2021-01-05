#!/bin/sh -ex

rake db:migrate;
rake db:seed;
rake user:list;
rake 'user:get[1]';
rake user:delete_first;
rake user:list | head;
rake user:create;
rake 'user:get[101]';
rake 'user:set_name[101, "User Name"]';
rake 'user:get[101]';

