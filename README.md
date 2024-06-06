# auto_venv
Bash script to manage python virtualenv while navigating the file system

# Installation

1. git clone this repo
1. cd into the repo
1. `cp auto_venv.sh ~/bin/`
1. `echo "source ~/bin/auto_venv.sh" >> ~/.bash_profile"`

# Synopsis

```
cd path/to/project
# Adds $PWD to an allow list. Activates virtualenv if present
auto_venv_allow 

# turns off virtualenv for path/to/project. If path/to_other/project is in the
# allow list and a virtualenv exists, activate it.
cd path/to_other/project 

# Removes $PWD from allow list. Deactivates virtualenv if active.
auto_venv_disallow 
```
