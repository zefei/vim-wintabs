# vim-wintabs

Wintabs is a per-window buffer manager for Vim. It creates "tabs" for each 
buffer opened in every Vim window, and displays these buffers either on tabline 
or statusline. It brings persistent contexts to Vim windows and tabs, making 
them more awesome.

# Screenshots

Wintabs with two native Vim tabs, showing buffers and tabs on tabline:

![image](https://raw.githubusercontent.com/zefei/vim-wintabs/master/screenshots/screenshot1.gif)

Wintabs with two Vim windows, showing buffers on statusline. It nicely preserves 
window layout when switching/closing tabs:

![image](https://raw.githubusercontent.com/zefei/vim-wintabs/master/screenshots/screenshot2.gif)

Wintabs manages long tablines nicely (better than Vim does!):

![image](https://raw.githubusercontent.com/zefei/vim-wintabs/master/screenshots/screenshot3.png)

# Installation

Use your favorite package manager to install:

* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/zefei/vim-wintabs ~/.vim/bundle/vim-wintabs`
* [Vundle](https://github.com/gmarik/Vundle.vim)
  * `Plugin 'zefei/vim-wintabs'`
* [NeoBundle](https://github.com/Shougo/neobundle.vim)
  * `NeoBundle 'zefei/vim-wintabs'`

# Usage

By default, wintabs maintains a list of buffers for each buffer opened in each 
window, and displays them on tabline. To navigate and manage these buffers, a 
few commands and key mappings are provided, and they are very similar to what 
Vim buffers/tabs have.

To make full use of wintabs, it is recommended to have the following commands or 
keys mapped, these are the essential ones:

    commands             | mapping keys                 | replacing Vim commands
    ---------------------+------------------------------+-----------------------
    :WintabsNext         | <Plug>(wintabs_next)         | :bn!
    :WintabsPrevious     | <Plug>(wintabs_previous)     | :bp!
    :WintabsClose        | <Plug>(wintabs_close)        | :bd
    :WintabsOnly         | <Plug>(wintabs_only)         |
    :WintabsCloseWindow  | <Plug>(wintabs_close_window) | :close, CTRL-W c
    :WintabsOnlyWindow   | <Plug>(wintabs_only_window)  | :only, CTRL-W o
    :WintabsCloseVimtab  | <Plug>(wintabs_close_vimtab) | :tabclose
    :WintabsOnlyVimtab   | <Plug>(wintabs_only_vimtab)  | :tabonly

Below is an example of key mappings:

    map <C-H> <Plug>(wintabs_previous)
    map <C-L> <Plug>(wintabs_next)
    map <C-T>c <Plug>(wintabs_close)
    map <C-T>o <Plug>(wintabs_only)
    map <C-W>c <Plug>(wintabs_close_window)
    map <C-W>o <Plug>(wintabs_only_window)
    command! Tabc WintabsCloseVimtab
    command! Tabo WintabsOnlyVimtab

See `:help wintabs-commands` for all available commands and mappings.

# Configuration

Wintabs has a handful of configuration options, see `:help wintabs-options` for 
details.

# FAQ

A: Does wintabs support Vim sessions?

Q: Yes, as long as your `sessionoptions` contains `"globals"`. Wintabs also 
supports [xolox/vim-session](https://github.com/xolox/vim-session) out of the 
box.

# License

MIT License.
