# outliner.vim

vim plugin to show a simple outliner.

<img src=images/outliner.png width="70%">

## Usage
Before using outliner.vim, you need to set `g:outliner_settings`.  
`g:outliner_settings` is a dictionary with a key of filetypes.  
'_' is also available, and this setting is applied when no filetype is matched.

Each item is a dictionary. Please see below and sample.vim.
```vim
let g:outliner_settings._ = {
            \ 'function': {         " <- tag name. any strings is available.
                \ 'pattern': '^{',  " <- 'pattern' key is required. this is used as a pattern of matching.
                \ 'line': -1,       " <- 'line' key is required. this is the offset from lines that matches the pattern.
                \}
            \}
```

Then show the outliner by this command.
`:OutLiner`

## Requirements

## Options
- `g:outliner_win_conf`  
    Dictionary of congfiguration.
    Following keys are available.
    - 'name' (string) default:'outliner'  
        Name of outliner window.
    - 'width' (number) default:30  
        Width of outliner window.
    - 'mod' (string) default:'topleft vertical'  
        Command modifiers of outliner window.
    - 'timer' (number) default:5000
        The repeating time to check the current line.
        If -1 is set, do not check the current line.

## Installation

For [vim-plug](https://github.com/junegunn/vim-plug) plugin manager:

```
Plug 'MeF0504/outliner.vim'
```

## License
[MIT](https://github.com/MeF0504/outliner.vim/blob/main/LICENSE)

## Author
[MeF0504](https://github.com/MeF0504)
