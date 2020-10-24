
# vim-pterm

This plugin provides to open and hide terminal in popupwin.  

![](https://raw.githubusercontent.com/rbtnn/vim-pterm/main/pterm.gif)

## Usage

### :PTermOpen[!] [{terminal-bufnr}]
With bang or not set {terminal-bufnr}: Open a new terminal in a popup window.  
Set {terminal-bufnr}: Open {terminal-bufnr} in a popup window.  
Height of the popup window is `eval(get(g:, 'pterm_height', '&lines / 2'))`.  
Width of the popup window is `eval(get(g:, 'pterm_width', '&columns / 2'))`.  

### :PTermHide
Close the popup window opened by `:PTermOpen`.  
This command is defined in a terminal buffer of `:PTermOpen`.  

## Keymappings
This plugin provides following keymappings. These keymappings can toggle it.  
If you do not want to these keymappings, please set `g:pterm_default_keymappings` to `v:false`.  

```
tnoremap <silent><C-z>   <C-w>:<C-u>PTermHide<cr>
nnoremap <silent><C-z>   :<C-u>PTermOpen<cr>
```

## Requirements

* Vim must be compiled with `+popupwin` feature

## License
Distributed under MIT License. See LICENSE.
