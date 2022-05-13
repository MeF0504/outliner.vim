" Name:         outliner.vim
" Description:  vim plugin to show a simple outliner.
" Author:       MeF

if exists('g:loaded_outliner')
    finish
endif
let g:loaded_outliner = 1

command! OutLiner call outliner#make_outliner()

