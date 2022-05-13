" Name:         outliner.vim
" Description:  vim plugin to show a simple outliner.
" Author:       MeF

let s:name_def = 'outliner.vim'
function! s:create_win() abort
    let width_def = 30
    let mod_def = 'topleft vertical'
    if exists('g:outliner_win_conf')
        if has_key(g:outliner_win_conf, 'width')
            let width = g:outliner_win_conf.width
        else
            let width = width_def
        endif
        if has_key(g:outliner_win_conf, 'mod')
            let mod = g:outliner_win_conf.mod
        else
            let mod = mod_def
        endif
        if has_key(g:outliner_win_conf, 'name')
            let name = g:outliner_win_conf.name
        else
            let name = s:name_def
        endif
    else
        let width = width_def
        let mod = mod_def
        let name = s:name_def
    endif

    execute printf('%s %dnew %s', mod, width, name)

    setlocal modifiable
    silent %delete _
    setlocal noreadonly
    setlocal noswapfile
    setlocal nobackup
    setlocal noundofile
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal nowrap
    setlocal foldlevel=9999
    setlocal report=9999
    setlocal winfixwidth
    setlocal nolist

    setlocal foldexpr=getline(v:lnum)[0]==\"\\t\"
    setlocal foldmethod=expr
    setlocal filetype=outliner
endfunction

function! <SID>outliner_jump() abort
    let line = getline('.')
    let idx = strridx(line, '@')
    if idx < 0
        return
    endif

    let lnum = line[idx+2:]
    wincmd p
    execute 'normal! '.lnum.'gg'
endfunction

function! s:outliner_highlight() abort
    syntax match OutLinerKeys /^\S.*/
    highlight default link OutLinerKeys Statement
endfunction

function! outliner#show_status() abort
    if !exists('b:status')
        return
    endif
    for key in keys(b:status)
        echohl Identifier
        echo key
        echohl None
        echon ': '
        echon b:status[key]
    endfor
endfunction

function! outliner#make_outliner() abort
    let b:status = {}

    let b:status.filetype = &filetype
    if !exists('g:outliner_settings')
        echohl ErrorMsg
        echo 'g:outliner_settings is not exists.'
        echohl None
        return
    endif
    if has_key(g:outliner_settings, b:status.filetype)
        let b:status.setting = g:outliner_settings[b:status.filetype]
    elseif has_key(g:outliner_settings, '_')
        let b:status.setting = g:outliner_settings['_']
    else
        echohl ErrorMsg
        echo printf('no settings for filetype "%s" exist in g:outliner_settings.', b:status.filetype)
        echohl None
        return
    endif

    let table = {}
    for k in keys(b:status.setting)
        let table[k] = []
    endfor

    for lnum in range(1, line('$'))
        let line = getline(lnum)
        for k in keys(b:status.setting)
            let pat = b:status.setting[k].pattern
            let shift = b:status.setting[k].line
            if match(line, pat) != -1
                call add(table[k], printf("\t%s @ %d", getline(lnum+shift), lnum+shift))
            endif
        endfor
    endfor
    let b:status.table = table

    let status = b:status
    call outliner#clear()
    call s:create_win()
    call append(0, [
                \ " Enter: jump to the line",
                \ "   -  : close fold",
                \ "   +  : open fold",
                \ ])
    for k in keys(status.setting)
        call append('$', k)
        call append('$', table[k])
        call append('$', '')
    endfor

    nnoremap <buffer> <CR> <Cmd>call <SID>outliner_jump()<CR>
    nnoremap <buffer> - zC
    nnoremap <buffer> + zO
    call s:outliner_highlight()
endfunction

function! outliner#clear() abort
    if exists('g:outliner_win_conf')
        if has_key(g:outliner_win_conf, 'name')
            let name = g:outliner_win_conf.name
        else
            let name = s:name_def
        endif
    else
        let name = s:name_def
    endif

    for win in range(1, winnr('$'))
        let winid = win_getid(win)
        let bufnr = winbufnr(winid)
        if bufname(bufnr) == name
            call win_execute(winid, 'quit')
        endif
    endfor
endfunction

