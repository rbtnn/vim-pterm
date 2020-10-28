

let g:loaded_pterm = 1

if has('nvim')
  echoerr '[pterm] This plugin does not support Neovim.'
  finish
elseif !has('popupwin')
  echoerr '[pterm] This plugin requires +popupwin feature.'
  finish
elseif v:versionlong < 8021900
  echoerr '[pterm] This plugin requires version8.2.1900 or above.'
  finish
endif

command! -count=0 -bang -nargs=? PTermOpen   call pterm#open(<q-bang>, <q-args>, <count>)

highlight default link PTerm    TabLine
highlight default link PTermSel TabLineSel

if get(g:, 'pterm_default_keymappings', v:true)
  tnoremap <silent><C-z>   <C-w>:<C-u>PTermHide<cr>
  nnoremap <silent><C-z>   :<C-u>PTermOpen<cr>
endif

augroup pterm
  autocmd!
  autocmd TabLeave * :call pterm#hide()
augroup END
