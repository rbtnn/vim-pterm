

let g:loaded_pterm = 1

if has('nvim')
  finish
endif

command! -bang -nargs=? -complete=customlist,PTermComplete PTermOpen   call pterm#open(<q-bang>, <q-args>)

if get(g:, 'pterm_default_keymappings', v:true)
  tnoremap <silent><C-z>   <C-w>:<C-u>PTermHide<cr>
  nnoremap <silent><C-z>   :<C-u>PTermOpen<cr>
endif
