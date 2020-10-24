
function! pterm#open(q_bang, q_args) abort
  call pterm#hide()
  let bnr = -1
  if empty(a:q_args)
    if ('!' == a:q_bang) || empty(term_list())
      let bnr = term_start([&shell], #{
        \   hidden: 1,
        \   term_finish: 'close',
        \ })
    else
      let bnr = term_list()[0]
    endif
  elseif -1 != index(term_list(), str2nr(a:q_args))
    let bnr = str2nr(a:q_args)
  endif
  if -1 != bnr
    call popup_create(bnr, #{
      \   pos: 'center',
      \   minheight: eval(get(g:, 'pterm_height', '&lines * 2 / 3')),
      \   maxheight: eval(get(g:, 'pterm_height', '&lines * 2 / 3')),
      \   minwidth: eval(get(g:, 'pterm_width', '&columns * 2 / 3')),
      \   maxwidth: eval(get(g:, 'pterm_width', '&columns * 2 / 3')),
      \ })
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

function! pterm#complete(ArgLead, CmdLine, CursorPos) abort
  return map(term_list(), { i,x -> string(x) })
endfunction

