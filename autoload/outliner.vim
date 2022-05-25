" Name:         outliner.vim
" Description:  vim plugin to show a simple outliner.
" Author:       MeF

function! s:get_config() abort
    let name_def = 'outliner'
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
            let name = name_def
        endif
    else
        let width = width_def
        let mod = mod_def
        let name = name_def
    endif
    return [width, mod, name]
endfunction

function! s:create_win() abort
    let [width, mod, name] = s:get_config()

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

    setlocal foldexpr=getline(v:lnum)[:3]==\"\ \ \ \ \"
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
    highlight default OutLinerPoint ctermbg=11 guibg=Yellow
endfunction

let s:bufid = -1
let s:popid = -1
function! s:outliner_line_display() abort
    call s:outliner_disp_close()
    let line = getline('.')
    let line = line[:strridx(line, '@')-1]
    if line[:3] != '    '
        return
    endif
    let numwidth = &numberwidth
    if len(line('$'))+1 > &numberwidth
        let numwidth = len(line('$'))
    endif
    if strdisplaywidth(line) <= winwidth(0)-&foldcolumn-numwidth
        return
    endif
    let thd = float2nr(0.9*&columns)
    if len(line) > thd
        let line = line[:thd]
    endif

    if has('popupwin')
        let pop_opt = #{
                    \ line: 'cursor',
                    \ col: 'cursor-'.(virtcol('.')-1),
                    \ pos: 'topleft',
                    \ wrap: v:false,
                    \ highlight: 'Normal',
                    \ }
        if s:popid < 0
            let s:popid = popup_create(line, pop_opt)
        else
            call popup_setoptions(s:popid, pop_opt)
            call popup_settext(s:popid, line)
        endif
        call win_execute(s:popid, 'setlocal cursorline')
    elseif has('nvim')
        if s:bufid < 0
            let s:bufid = nvim_create_buf(v:false, v:true)
        endif
        call nvim_buf_set_lines(s:bufid, 0, -1, 0, [line])
        let pop_opt = {
                    \ 'relative': 'cursor',
                    \ 'anchor': 'NW',
                    \ 'height': 1,
                    \ 'width': len(line),
                    \ 'row': 0,
                    \ 'col': -virtcol('.')+1,
                    \ 'focusable': v:false,
                    \ 'style': 'minimal',
                    \ }
        if s:popid < 0
            let s:popid = nvim_open_win(s:bufid, v:false, pop_opt)
        else
            call nvim_win_set_config(s:popid, pop_opt)
        endif
        call win_execute(s:popid, "setlocal winhighlight=Normal:Normal")
        call win_execute(s:popid, 'setlocal cursorline')
    endif
endfunction

function! s:outliner_disp_close() abort
    if s:popid >= 0
        if has('popupwin')
            call popup_close(s:popid)
        elseif has('nvim')
            call nvim_win_close(s:popid, v:false)
        endif
        let s:popid = -1
    endif
endfunction

function! s:outliner_show_line() abort
    let line = getline('.')
    if line[:3] == '    '
        echo line[4:]
    endif
endfunction

function! <SID>outliner_hi_curpos(pre_winid, ol_winid, timer_id) abort
    echomsg a:pre_winid
    let lnum = line('.', a:pre_winid)
    let [width, mod, name] = s:get_config()
    let pre_num = 0
    for i in range(1, line('$' a:ol_winid))
        let line = getbufline(name, i)[0]
        if line[:3] == '    '
            let idx = strridx(line, '@')
            if idx < 0
                return
            endif
            let num = line[idx+2:]
            if num > lnum && pre_num <= lnum
                call win_execute(a:ol_winid, "matchaddpos('OutLinerPoint', [[i-1,2],[i-1,3]])")
            endif
        endif
    endfor
endfunction

function! s:outliner_set_autocmd() abort
    augroup outliner
        autocmd!
        autocmd CursorMoved <buffer> call s:outliner_line_display()
        autocmd BufLeave <buffer> call s:outliner_disp_close()
        autocmd CursorHold <buffer> call s:outliner_show_line()
    augroup END
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
                call add(table[k], printf("    %s @ %d", getline(lnum+shift), lnum+shift))
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
    setlocal nomodifiable

    nnoremap <buffer> <CR> <Cmd>call <SID>outliner_jump()<CR>
    nnoremap <buffer> - zC
    nnoremap <buffer> + zO
    call s:outliner_highlight()
    call s:outliner_set_autocmd()
    let pre_winid = win_getid(winnr('#'))
    let winid = win_getid()
    " call timer_start(5000, function(expand('<SID>').'outliner_hi_curpos', [pre_winid, winid]), {'repeat':-1})
endfunction

function! outliner#clear() abort
    let name = s:get_config()[2]

    for win in range(1, winnr('$'))
        let winid = win_getid(win)
        let bufnr = winbufnr(winid)
        if bufname(bufnr) == name
            call win_execute(winid, 'quit')
        endif
    endfor
endfunction

