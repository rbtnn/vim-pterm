
function! pterm#open(q_bang, q_args, count) abort
  call pterm#hide()
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
    command! -buffer -nargs=0 PTermHide   call pterm#hide()
  endif
endfunction

function! pterm#hide() abort
  let winid = win_getid()
  if -1 != index(popup_list(), winid)
    if getwininfo(winid)[0]['terminal']
      call popup_close(winid)
    endif
  endif
endfunction

