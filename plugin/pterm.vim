

let g:loaded_pterm = 1

if has('nvim') || !has('popupwin')
  finish
endif

command! -count=0 -bang -nargs=? PTermOpen   call pterm#open(<q-bang>, <q-args>, <count>)

if get(g:, 'pterm_default_keymappings', v:true)
  tnoremap <silent><C-z>   <C-w>:<C-u>PTermHide<cr>
  nnoremap <silent><C-z>   :<C-u>PTermOpen<cr>
endif

