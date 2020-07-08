#! /usr/bin/env bash

echo "Dependencies: vim"

#Setup symlinks for vim
mv $HOME/.vimrc $HOME/.vimrc-old
ln -s $PWD/vim/vimrc $HOME/.vimrc

#mkdir ~/.config
ln -s ~/.vimrc ~/.config/nvim/init.vim
mkdir -p ~/.config/nvim/site/autoload
cp $PWD/vim/autoload/plug.vim ~/.config/nvim/site/autoload/plug.vim

# Install vim plugins
vim +PlugInstall +qall

#setup symlink for bash
mv $HOME/.bash_profile $HOME/.bash_profile-old
mv $HOME/.zshrc $HOME/.zshrc-old
ln -s $PWD/bash/bash_profile $HOME/.bash_profile
ln -s $PWD/zsh/zshrc $HOME/.zshrc
