
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

4. __Pinned:__  
    Open the terminal-buffer in a popup window if a pinned terminal-buffer exists.

5. __Otherwise:__  
    Open the first of existing terminal-buffers in a popup window.   
    If terminal-buffer does not exist, open a new terminal in a popup window.  

Height of the popup window is `eval(get(g:, 'pterm_height', '(&lines - 2 - &cmdheight) * 2 / 3'))`.  
Width of the popup window is `eval(get(g:, 'pterm_width', '&columns * 2 / 3'))`.  
The way to set other options of the popup window is to set `g:pterm_options`.  
e.g. `:let g:pterm_options = { 'border' : [], }`  

### :PTermHide
Close the popup window opened by `:PTermOpen`.  
This command is defined only in a terminal buffer of `:PTermOpen`.  

### :PTermPin
Pin/Unpin the terminal-buffer to current tabpage.  
This command is defined only in a terminal buffer of `:PTermOpen`.  

### :PTermNext
Switch to the next terminal-buffer. This is similar to `:bnext`.  
This command is defined only in a terminal buffer of `:PTermOpen`.  

### :PTermPrevious
Switch to the next terminal-buffer. This is similar to `:bprevious`.  
This command is defined only in a terminal buffer of `:PTermOpen`.  

## Keymappings
This plugin provides following keymappings. These keymappings can toggle it.  
If you do not want to these keymappings, please set `g:pterm_default_keymappings` to `v:false`.  

```
tnoremap <silent><C-z>   <C-w>:<C-u>PTermHide<cr>
nnoremap <silent><C-z>   :<C-u>PTermOpen<cr>
```

Also this plugin provides following keymappings only in a terminal buffer of `:PTermOpen`.  
If you do not want to these keymappings, please set `g:pterm_default_extra_keymappings` to `v:false`.  

```
tnoremap <buffer><silent><C-t>       <C-w>:<C-u>PTermOpen!<cr>
tnoremap <buffer><silent>gt          <C-w>:<C-u>PTermNext<cr>
nnoremap <buffer><silent>gT          <C-w>:<C-u>PTermPrevious<cr>
```

## Installation
This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-pterm'
```

## Requirements
* Vim must be compiled with `+popupwin` feature
* Vim version 8.2.1900 or above

## License
Distributed under MIT License. See LICENSE.

