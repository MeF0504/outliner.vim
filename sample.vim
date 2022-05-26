
let g:outliner_settings = {}

let g:outliner_settings._ = {
            \ 'function': {
                \ 'pattern': '^{',
                \ 'line': -1,
                \}
            \}

let g:outliner_settings.vim = {
            \ 'function': {
                \ 'pattern': '^\s*function',
                \ 'line': 0,
                \ },
            \ 'map': {
                \ 'pattern': '^[a-z]*map ',
                \ 'line': 0,
                \},
            \ }

let g:outliner_settings.python = {
            \ 'function': {
                \ 'pattern': '^\s*def',
                \ 'line': 0,
                \},
            \ 'class': {
                \ 'pattern': '^\s*class',
                \ 'line': 0,
                \},
            \}

let g:outliner_win_conf = {
            \ 'name': 'outliner',
            \ 'width': 30,
            \ 'mod': 'topleft vertical',
            \ 'timer': 5000,
            \ }

