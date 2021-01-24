# Virtual Environment
When contributing better to use a virtual environment. If you are planning to
create a virtual environment please do follow the following steps:

## Install virtual environment
Do use pip3 as we want to use python 3.x.x
```
sudo pip3 install virtualenv
```

## Create virtual environment
The following folder is added to .gitignore so that when pushing the code the
virtual environment files will not be pushed.
```
virtualenv vitess-framework-testing
```

## Activate virtual environment
Points python variables to the new path
```
source vitess-framework-testing/bin/activate
```

## Proof that it works
```
which python

Ex Output:
vitess-framework-testing/bin/python
```
