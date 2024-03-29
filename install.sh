#! /usr/bin/env bash

echo "Dependencies: nvim"

# Ensure directories
ln -s $PWD/nvim $HOME/.config/nvim

# Commands to link all default editors to nvim
# NVIM_PATH=/usr/local/bin/nvim.appimage
# set -u
# sudo update-alternatives --install /usr/bin/ex ex "${NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/vi vi "${NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/view view "${NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/vim vim "${NVIM_PATH}" 110
# sudo update-alternatives --install /usr/bin/vimdiff vimdiff "${NVIM_PATH}" 110

# Install vim plugins
nvim +PlugInstall +qall

#setup symlink for bash
mv $HOME/.bash_profile $HOME/.bash_profile-old
mv $HOME/.zshrc $HOME/.zshrc-old
ln -s $PWD/bash/bash_profile $HOME/.bash_profile
ln -s $PWD/zsh/zshrc $HOME/.zshrc
