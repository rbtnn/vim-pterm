
function! pterm#open(q_bang, q_args, count) abort
  let reopen = (-1 == index(popup_list(), win_getid()))

  call pterm#hide()

  " Do not show pterm if current window is pterm.
  if reopen
    let pinned_bnr = get(t:, 'pterm_pinned', 0)
    let bnr = -1
    if -1 != index(term_list(), a:count)
      let bnr = a:count
    else
      let new_term = v:false
      if ('!' == a:q_bang) || !empty(a:q_args)
        let new_term = v:true
      else
        if empty(term_list())
          let new_term = v:true
        elseif -1 != index(term_list(), pinned_bnr)
          let bnr = pinned_bnr
        else
          let bnr = term_list()[0]
        endif
      endif
      if new_term
        let args = empty(a:q_args) ? [&shell] : split(a:q_args, ' ')
        let bnr = term_start(args, #{
          \   hidden: 1,
          \   term_finish: 'close',
          \   term_kill: empty(a:q_args) ? 'term' : '',
          \   exit_cb: function('pterm#exit_cb'),
          \ })
      endif
    endif
    if -1 != bnr
      let options = extend(#{
        \   pos: 'center',
        \   minheight: eval(get(g:, 'pterm_height', '&lines * 2 / 3')),
        \   maxheight: eval(get(g:, 'pterm_height', '&lines * 2 / 3')),
        \   minwidth: eval(get(g:, 'pterm_width', '&columns * 2 / 3')),
        \   maxwidth: eval(get(g:, 'pterm_width', '&columns * 2 / 3')),
        \ }, get(g:, 'pterm_options', {}))
      let winid = popup_create(bnr, options)
      if -1 != index(term_list(), pinned_bnr)
        call pterm#pin(v:false, v:false)
      endif
      command! -buffer -nargs=0 PTermPin      call pterm#pin(v:false, v:true)
      command! -buffer -nargs=0 PTermHide     call pterm#hide()
    endif
  endif
endfunction

function! pterm#exit_cb(ch, msg) abort
  call pterm#hide()
endfunction

function! pterm#hide() abort
  let winid = s:get_winid_of_pterm()
  if 0 < winid
    call pterm#pin(v:true, v:false)
    call popup_close(winid)
  endif
endfunction

function! pterm#pin(hide, toggle) abort
  if a:toggle
    let pinned_bnr = get(t:, 'pterm_pinned', 0)
    if -1 != index(term_list(), pinned_bnr)
      silent! unlet t:pterm_pinned
    else
      let t:pterm_pinned = bufnr()
    endif
  endif

  let winid = s:get_winid_of_pterm()

  if a:hide || !exists('t:pterm_pinned')
    let pinned_winid = getwinvar(winid, 'pinned_winid', 0)
    if 0 < pinned_winid
      call popup_close(pinned_winid)
    endif
  else
    let pos = popup_getpos(winid)
    call setwinvar(winid, 'pinned_winid', popup_create(printf('[Pinned:%d]', bufnr()), #{
      \ highlight: 'PTermPin',
      \ line: pos['line'] - 1,
      \ col: pos['col'],
      \ }))
  endif
endfunction

function! s:get_winid_of_pterm() abort
  for winid in popup_list()
    if get(getwininfo(winid), 0, { 'terminal' : v:false })['terminal']
      return winid
    endif
  endfor
  return 0
endfunction

