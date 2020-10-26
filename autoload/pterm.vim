
function! pterm#open(q_bang, q_args, count) abort
  let reopen = (-1 == index(popup_list(), win_getid()))

  call pterm#hide()

  " Do not show pterm if current window is pterm.
  if reopen
    let bnr = -1
    if -1 != index(term_list(), a:count)
      let bnr = a:count
    else
      let new_term = v:false
      if ('!' == a:q_bang) || !empty(a:q_args)
        let new_term = v:true
      else
        let pinned_bnr = get(get(t:, 'pterm_pinned', []), 0, 0)
        if -1 != index(term_list(), pinned_bnr)
          let bnr = pinned_bnr
        elseif empty(term_list())
          let new_term = v:true
        else
          let bnr = term_list()[0]
        endif
      endif
      if new_term
        let args = empty(a:q_args) ? [&shell] : split(a:q_args, "\n")
        let bnr = term_start(args, #{
          \   hidden: 1,
          \   term_finish: 'close',
          \   term_kill: empty(a:q_args) ? 'term' : '',
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
      call popup_create(bnr, options)
      command! -buffer -nargs=0 PTermHide     call pterm#hide()
      command! -buffer -nargs=0 PTermPinned   call pterm#pinned()
    endif
  endif
endfunction

function! pterm#hide() abort
  for winid in popup_list()
    if get(getwininfo(winid), 0, { 'terminal' : v:false })['terminal']
      call popup_close(winid)
    endif
  endfor
endfunction

function! pterm#pinned() abort
  let t:pterm_pinned = [bufnr()]
endfunction

