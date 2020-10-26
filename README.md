
# vim-pterm
This plugin provides to open and hide terminal in a popup window.  

![](https://raw.githubusercontent.com/rbtnn/vim-pterm/main/pterm.gif)

## Commands

### :[{terminal-bufnr}]PTermOpen[!] [{arguments}]
1. __Set {terminal-bufnr}:__  
    Open {terminal-bufnr} in a popup window.  

2. __With bang:__  
    Open a new terminal in a popup window.  

3. __Set {arguments}:__  
    Open a new terminal of {arguments} in a popup window.  
    e.g. `:PTermOpen powershell`, `:PTermOpen sh`  

4. __Otherwise:__  
    Open the first of existing terminal-buffers in a popup window.   
    If terminal-buffer does not exist, open a new terminal in a popup window.  

Height of the popup window is `eval(get(g:, 'pterm_height', '&lines * 2 / 3'))`.  
Width of the popup window is `eval(get(g:, 'pterm_width', '&columns * 2 / 3'))`.  
The way to set other options of the popup window is to set `g:pterm_options`.  
e.g. `:let g:pterm_options = { 'border' : [], }`  

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

## Installation
This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-pterm'
```

## Requirements
* Vim must be compiled with `+popupwin` feature
* Recommend Vim version 8.2.1900 or later

## License
Distributed under MIT License. See LICENSE.

