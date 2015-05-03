## Cloning the repo ##
```
$ git clone --recursive git://github.com/manidesto/dotfiles.git
```
or
```
$ git clone git://github.com/manidesto/dotfiles.git
$ git submodule update --init --recursive
```

## Install Vim Plugins ##
Not all plugins requiers this step
#### YouCompleteMe ####
```
$ cd vim/bundle/YouCompleteMe
$ ./install.sh
```

## Create symlinks ##
```
$ ln -s ~/dotfiles/vim ~/.vim
$ ln -s ~/dotfiles/vim/vimrc ~/.vimrc
$ ln -s ~/dotfiles/bash/bash_profile ~/.bash_profile
```

## Add bash_profile_user ##
In "bash/bash_profile", include "bash_profile_user"(Your custom directory aliases etc.)
