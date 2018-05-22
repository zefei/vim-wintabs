if exists('g:loaded_wintabs') || v:version < 700
  finish
endif
let g:loaded_wintabs = 1

" key mappings
nnoremap <silent> <Plug>(wintabs_next) :<C-U>WintabsNext<CR>
nnoremap <silent> <Plug>(wintabs_previous) :<C-U>WintabsPrevious<CR>
nnoremap <silent> <Plug>(wintabs_close) :<C-U>WintabsClose<CR>
nnoremap <silent> <Plug>(wintabs_undo) :<C-U>WintabsUndo<CR>
nnoremap <silent> <Plug>(wintabs_only) :<C-U>WintabsOnly<CR>
nnoremap <silent> <Plug>(wintabs_all) :<C-U>WintabsAll<CR>
nnoremap <silent> <Plug>(wintabs_close_window) :<C-U>WintabsCloseWindow<CR>
nnoremap <silent> <Plug>(wintabs_only_window) :<C-U>WintabsOnlyWindow<CR>
nnoremap <silent> <Plug>(wintabs_close_vimtab) :<C-U>WintabsCloseVimtab<CR>
nnoremap <silent> <Plug>(wintabs_only_vimtab) :<C-U>WintabsOnlyVimtab<CR>
nnoremap <silent> <Plug>(wintabs_tab_1) :<C-U>WintabsGo 1<CR>
nnoremap <silent> <Plug>(wintabs_tab_2) :<C-U>WintabsGo 2<CR>
nnoremap <silent> <Plug>(wintabs_tab_3) :<C-U>WintabsGo 3<CR>
nnoremap <silent> <Plug>(wintabs_tab_4) :<C-U>WintabsGo 4<CR>
nnoremap <silent> <Plug>(wintabs_tab_5) :<C-U>WintabsGo 5<CR>
nnoremap <silent> <Plug>(wintabs_tab_6) :<C-U>WintabsGo 6<CR>
nnoremap <silent> <Plug>(wintabs_tab_7) :<C-U>WintabsGo 7<CR>
nnoremap <silent> <Plug>(wintabs_tab_8) :<C-U>WintabsGo 8<CR>
nnoremap <silent> <Plug>(wintabs_tab_9) :<C-U>WintabsGo 9<CR>
nnoremap <silent> <Plug>(wintabs_first) :<C-U>WintabsFirst<CR>
nnoremap <silent> <Plug>(wintabs_last) :<C-U>WintabsLast<CR>
nnoremap <silent> <Plug>(wintabs_move_left) :<C-U>WintabsMove -1<CR>
nnoremap <silent> <Plug>(wintabs_move_right) :<C-U>WintabsMove 1<CR>
nnoremap <silent> <Plug>(wintabs_move_to_window_left) :<C-U>WintabsMoveToWindow h<CR>
nnoremap <silent> <Plug>(wintabs_move_to_window_right) :<C-U>WintabsMoveToWindow l<CR>
nnoremap <silent> <Plug>(wintabs_move_to_window_above) :<C-U>WintabsMoveToWindow k<CR>
nnoremap <silent> <Plug>(wintabs_move_to_window_below) :<C-U>WintabsMoveToWindow j<CR>
nnoremap <silent> <Plug>(wintabs_move_to_window_next) :<C-U>WintabsMoveToWindow w<CR>
nnoremap <silent> <Plug>(wintabs_maximize) :<C-U>WintabsMaximize<CR>
nnoremap <silent> <Plug>(wintabs_refresh) :<C-U>WintabsRefresh<CR>

" commands
command! WintabsNext call wintabs#jump(1)
command! WintabsPrevious call wintabs#jump(-1)
command! WintabsClose call wintabs#close()
command! WintabsUndo call wintabs#undo()
command! WintabsOnly call wintabs#only()
command! WintabsAll call wintabs#all()
command! WintabsAllBuffers call wintabs#all_buffers()
command! WintabsCloseWindow call wintabs#close_window()
command! WintabsOnlyWindow call wintabs#only_window()
command! WintabsCloseVimtab call wintabs#close_vimtab()
command! WintabsOnlyVimtab call wintabs#only_vimtab()
command! -nargs=1 WintabsGo call wintabs#go(<q-args> + 0)
command! WintabsFirst call wintabs#go(1)
command! WintabsLast call wintabs#go(-1)
command! -nargs=1 WintabsMove call wintabs#move(<q-args> + 0)
command! -nargs=1 WintabsMoveToWindow call wintabs#move_to_window(<q-args>)
command! WintabsMaximize call wintabs#maximize()
command! -nargs=1 WintabsDo call wintabs#do(<q-args>)
command! WintabsRefresh call wintabs#init()

" configurations
function! s:set(var, value)
  if !exists(a:var)
    let {a:var} = a:value
  endif
endfunction

" major
call s:set('g:wintabs_display', 'tabline')
call s:set('g:wintabs_autoclose', 1)
call s:set('g:wintabs_autoclose_vim', 0)
call s:set('g:wintabs_autoclose_vimtab', 0)
call s:set('g:wintabs_switchbuf', &switchbuf)
if exists('g:loaded_airline') && g:loaded_airline
  call s:set('g:wintabs_statusline', '%!airline#statusline(winnr())')
elseif exists('g:loaded_lightline') && g:loaded_lightline
  call s:set('g:wintabs_statusline', '%!lightline#statusline(0)')
elseif !empty(&statusline)
  call s:set('g:wintabs_statusline', '%#StatusLine#'.&statusline.'%##')
else
  call s:set('g:wintabs_statusline', '')
endif
call s:set('g:wintabs_reverse_order', 0)
call s:set('g:wintabs_ignored_filetypes', ['gitcommit', 'vundle', 'qf', 'vimfiler'])
call s:set('g:wintabs_renderers', wintabs#renderers#defaults())

" ui
call s:set('g:wintabs_ui_modified', ' +')
call s:set('g:wintabs_ui_readonly', ' -')
call s:set('g:wintabs_ui_sep_leftmost', ' ')
call s:set('g:wintabs_ui_sep_inbetween', '|')
call s:set('g:wintabs_ui_sep_rightmost', '|')
call s:set('g:wintabs_ui_active_left', ' ')
call s:set('g:wintabs_ui_active_right', ' ')
call s:set('g:wintabs_ui_buffer_name_format', ' %t ')
call s:set('g:wintabs_ui_show_vimtab_name', 0)
if g:wintabs_ui_show_vimtab_name == 0
  call s:set('g:wintabs_ui_vimtab_name_format', '%n')
elseif g:wintabs_ui_show_vimtab_name == 1
  call s:set('g:wintabs_ui_vimtab_name_format', '%t')
else
  call s:set('g:wintabs_ui_vimtab_name_format', '%n:%t')
endif
call s:set('g:wintabs_ui_active_vimtab_left', ' ')
call s:set('g:wintabs_ui_active_vimtab_right', ' ')

if g:wintabs_display == 'tabline'
  call s:set('g:wintabs_ui_active_higroup', 'TabLineSel')
endif

if g:wintabs_display == 'statusline'
  call s:set('g:wintabs_ui_active_higroup', 'Normal')
endif

" private
call s:set('g:wintabs_ui_arrow_left', ' < ')
call s:set('g:wintabs_ui_arrow_right', ' > ')
call s:set('g:wintabs_ui_sep_spaceline', '|')
call s:set('g:wintabs_undo_limit', 100)

" init session
call wintabs#session#init()

" init undo list
call wintabs#undo#init()

" start wintabs
call wintabs#init()
