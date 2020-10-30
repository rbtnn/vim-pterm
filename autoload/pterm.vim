
function! pterm#open(...) abort
  let term_bufnr = get(a:000, 0, 0)
  let q_bang = get(a:000, 1, '')
  let q_args = get(a:000, 2, '')

  let reopen = (-1 == index(popup_list(), win_getid()))

  call pterm#hide()

  if reopen || ('!' == q_bang) || !empty(q_args) || (-1 != index(pterm#list(), term_bufnr))
    let pinned_bnr = get(t:, 'pterm_pinned', 0)
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
        elseif -1 != index(pterm#list(), pinned_bnr)
          let bnr = pinned_bnr
        else
          let bnr = pterm#list()[0]
        endif
      endif
      if new_term
        let args = empty(q_args) ? &shell : q_args
        let bnr = term_start(args, #{
          \   hidden: 1,
          \   term_highlight: get(g:, 'pterm_term_highlight', 'Terminal'),
          \   term_finish: 'close',
          \   term_kill: empty(q_args) ? 'term' : '',
          \   exit_cb: function('s:exit_cb'),
          \ })
      endif
    endif
    if -1 != bnr
      let width = eval(get(g:, 'pterm_width', '&columns * 2 / 3'))
      let height = eval(get(g:, 'pterm_height', '(&lines - 2 - &cmdheight) * 2 / 3'))
      let line = eval(get(g:, 'pterm_line', '(&lines - eval(height)) / 2'))
      let col = eval(get(g:, 'pterm_col', '(&columns - eval(width)) / 2'))
      let tabline_height = (2 == &showtabline) || ((1 == &showtabline) && (1 < tabpagenr()))
      let statusline_height = 1
      let tabs_height = 1
      if line < 1 + tabs_height + tabline_height
        let line = 1 + tabs_height + tabline_height
      endif
      if &lines < height + tabs_height + tabline_height + statusline_height + &cmdheight
        let height = &lines - tabs_height - tabline_height - statusline_height - &cmdheight
      endif
      let options = extend(#{
        \   pos: 'topleft',
        \   highlight: get(g:, 'pterm_term_highlight', 'Terminal'),
        \   minheight: height, maxheight: height,
        \   minwidth: width, maxwidth: width,
        \   line: line, col: col,
        \ }, get(g:, 'pterm_options', {}))
      let winid = popup_create(bnr, options)
      call s:show_tabs()
      command! -buffer -nargs=0 PTermPin      call pterm#pin()
      command! -buffer -nargs=0 PTermHide     call pterm#hide()
      command! -buffer -nargs=0 PTermNext     call pterm#next()
      command! -buffer -nargs=0 PTermPrevious call pterm#previous()
      if get(g:, 'pterm_default_extra_keymappings', v:true)
        tnoremap <buffer><silent><C-t>       <C-w>:<C-u>PTermOpen!<cr>
        tnoremap <buffer><silent>gt          <C-w>:<C-u>PTermNext<cr>
        tnoremap <buffer><silent>gT          <C-w>:<C-u>PTermPrevious<cr>
      endif
      if 'n' == mode()
        call call('cursor', get(b:, 'pterm_last_curpos', [1, 1]))
      endif
    endif
  endif
endfunction

function! pterm#hide() abort
  let winid = s:get_winid_of_pterm()
  if 0 < winid
    if 'n' == mode()
      let b:pterm_last_curpos = getcurpos()[1:2]
    endif
    call s:hide_tabs()
    call popup_close(winid)
  endif
endfunction

function! pterm#pin() abort
  let pinned_bnr = get(t:, 'pterm_pinned', 0)
  if -1 != index(pterm#list(), pinned_bnr)
    silent! unlet t:pterm_pinned
  else
    let t:pterm_pinned = bufnr()
  endif
  call s:show_tabs()
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
  call filter(xs, { i,x -> -1 == index(showterms, x) })
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

function! s:show_tabs() abort
  call s:hide_tabs()
  let winid = s:get_winid_of_pterm()
  let pos = popup_getpos(winid)
  if 1 <= pos['line'] - 1
    let tab_winids = []
    let offset = 0
    let xs = []
    for n in pterm#list()
      let pinned_text = (get(t:, 'pterm_pinned', 0) == n) ? '*' : ''
      if n == bufnr()
        let xs += [#{
          \ text: printf(' [%s%d] ', pinned_text, n),
          \ high: 'PTermSel',
          \ offset: offset,
          \ }]
      else
        let xs += [#{
          \ text: printf('  %s%d  ', pinned_text, n),
          \ high: 'PTerm',
          \ offset: offset,
          \ }]
      endif
      let offset += len(xs[-1]['text'])
    endfor
    for x in xs
      let tab_winids += [popup_create(x['text'], #{
        \ highlight: x['high'],
        \ line: pos['line'] - 1,
        \ col: pos['col'] + (offset - x['offset'] - len(x['text'])),
        \ })]
    endfor
    call setwinvar(winid, 'tab_winids', tab_winids)
  endif
endfunction

function! s:hide_tabs() abort
  let winid = s:get_winid_of_pterm()
  for n in getwinvar(winid, 'tab_winids', [])
    call popup_close(n)
  endfor
  call setwinvar(winid, 'tab_winids', [])
endfunction

