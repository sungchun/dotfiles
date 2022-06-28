#!/bin/bash

mkdir -p ~/.config/nvim
stow --target "$HOME" --restow dotfiles

