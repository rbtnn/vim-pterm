
function! pterm#open(...) abort
    let term_bufnr = get(a:000, 0, 0)
    let q_bang = get(a:000, 1, '')
    let q_args = get(a:000, 2, '')

    let reopen = (-1 == index(popup_list(), win_getid()))

    call pterm#hide()

    if reopen || ('!' == q_bang) || !empty(q_args) || (-1 != index(pterm#list(), term_bufnr))
        let bnr = -1
        if -1 != index(pterm#list(), term_bufnr)
            let bnr = term_bufnr
        else
            let new_term = v:false
            if ('!' == q_bang) || !empty(q_args)
                let new_term = v:true
            else
                if empty(pterm#list())
                    let new_term = v:true
                else
                    let bnr = get(t:, 'pterm_recent_bufnr', 0)
                    if -1 == index(pterm#list(), bnr)
                        let bnr = pterm#list()[0]
                    endif
                endif
            endif
            if new_term
                let args = empty(q_args) ? &shell : q_args
                let bnr = term_start(args, {
                    \   'hidden' : 1,
                    \   'term_highlight' : get(g:, 'pterm_term_highlight', 'Terminal'),
                    \   'term_finish' : 'close',
                    \   'term_kill' : empty(q_args) ? 'term' : '',
                    \   'exit_cb' : function('s:exit_cb'),
                    \ })
            endif
        endif
        if -1 != bnr
            let winid = popup_create(bnr, pterm#build_options())
            call s:show_tabs()
            command! -buffer -nargs=0 PTermHide     call pterm#hide()
            command! -buffer -nargs=0 PTermNext     call pterm#next()
            command! -buffer -nargs=0 PTermPrevious call pterm#previous()
            if get(g:, 'pterm_default_extra_keymappings', v:true)
                tnoremap <buffer><silent><C-t>       <C-w>:<C-u>PTermOpen!<cr>
                tnoremap <buffer><silent>gt          <C-w>:<C-u>PTermNext<cr>
                tnoremap <buffer><silent>gT          <C-w>:<C-u>PTermPrevious<cr>
            endif
            if 'n' == mode()
                let n = get(b:, 'pterm_recent_topline', 1) - 1
                if 0 < n
                    call feedkeys(printf("gg%d\<C-e>", n), 'xn')
                endif
                call setpos('.', get(b:, 'pterm_recent_curpos', []))
            endif
        endif
    endif
endfunction

function! pterm#build_options() abort
    let width = &columns * 4 / 5
    let height = &lines * 4 / 5
    let line = (&lines - height) / 2
    let col = (&columns - width) / 2
    return extend({
        \   'border' : [], 'borderhighlight' : ['Label'],
        \   'pos' : 'topleft',
        \   'highlight' : get(g:, 'pterm_term_highlight', 'Terminal'),
        \   'minheight' : height, 'maxheight' : height,
        \   'minwidth' : width, 'maxwidth' : width,
        \   'line' : line, 'col' : col,
        \   'callback' : function('s:popup_cb'),
        \ }, get(g:, 'pterm_options', {}), 'force')
endfunction

function! pterm#hide() abort
    let winid = s:get_winid_of_pterm()
    if 0 < winid
        call popup_close(winid)
    endif
endfunction

function! pterm#next() abort
    let winid = s:get_winid_of_pterm()
    if 0 < winid
        let xs = pterm#list()
        if 1 < len(xs)
            let i = index(xs, bufnr()) - 1
            if -1 == i
                let i = len(xs) - 1
            endif
            call pterm#open(xs[i])
        endif
    endif
endfunction

function! pterm#previous() abort
    let winid = s:get_winid_of_pterm()
    if 0 < winid
        let xs = pterm#list()
        if 1 < len(xs)
            let i = index(xs, bufnr()) + 1
            if len(xs) == i
                let i = 0
            endif
            call pterm#open(xs[i])
        endif
    endif
endfunction

function! pterm#list() abort
    let xs = term_list()
    let showterms = map(filter(getwininfo(), { i,x -> x['terminal'] }), { i,x -> x['bufnr'] })
    call filter(xs, { _, x -> (-1 == index(showterms, x)) && ('finished' != term_getstatus(x)) })
    return xs
endfunction

function! s:get_winid_of_pterm() abort
    for winid in popup_list()
        if get(getwininfo(winid), 0, { 'terminal' : v:false })['terminal']
            return winid
        endif
    endfor
    return 0
endfunction

function! s:exit_cb(ch, msg) abort
    let xs = pterm#list()
    let i = index(xs, bufnr())
    call filter(xs, { i,x -> 'finished' != term_getstatus(x) })
    if empty(xs)
        call pterm#hide()
    else
        if 0 <= i - 1
            call pterm#open(xs[i - 1])
        else
            call pterm#open(xs[0])
        endif
        redraw
    endif
endfunction

function! s:popup_cb(winid, result) abort
    let t:pterm_recent_bufnr = winbufnr(a:winid)
    if 0 != t:pterm_recent_bufnr
        call setbufvar(t:pterm_recent_bufnr, 'pterm_recent_topline', get(get(getwininfo(a:winid), 0, {}), 'topline', 1))
        call setbufvar(t:pterm_recent_bufnr, 'pterm_recent_curpos', getcurpos(a:winid))
    endif
endfunction

function! s:show_tabs() abort
    let winid = s:get_winid_of_pterm()
    let pos = popup_getpos(winid)
    if 1 <= pos['line']
        let offset = 0
        let xs = []
        for n in pterm#list()
            if n == bufnr()
                let xs += [{
                    \ 'text' : printf(' [%d] ', n),
                    \ 'high' : 'PTermSel',
                    \ 'offset' : offset,
                    \ }]
            else
                let xs += [{
                    \ 'text' : printf('  %d  ', n),
                    \ 'high' : 'PTerm',
                    \ 'offset' : offset,
                    \ }]
            endif
            let offset += len(xs[-1]['text'])
        endfor
        let title = ''
        for x in xs
            let title = x['text'] .. title
        endfor
        call popup_setoptions(winid, { 'title' : title, })
    endif
endfunction

