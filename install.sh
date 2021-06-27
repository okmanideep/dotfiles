#! /usr/bin/env bash

echo "Dependencies: vim"

# Ensure directories
mkdir -p $HOME/.config/nvim/site/autoload
mv $HOME/.config/nvim/init.vim $HOME/.config/nvim/backup-init.vim
ln -s $PWD/vim/vimrc $HOME/.config/nvim/init.vim
cp $PWD/vim/autoload/plug.vim $HOME/.config/nvim/site/autoload/plug.vim

# Install vim plugins
nvim +PlugInstall +qall

#setup symlink for bash
mv $HOME/.bash_profile $HOME/.bash_profile-old
mv $HOME/.zshrc $HOME/.zshrc-old
ln -s $PWD/bash/bash_profile $HOME/.bash_profile
ln -s $PWD/zsh/zshrc $HOME/.zshrc
