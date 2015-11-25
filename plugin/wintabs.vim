if exists('g:loaded_wintabs') || v:version < 700
  finish
endif
let g:loaded_wintabs = 1

" key mappings
nnoremap <silent> <Plug>(wintabs_next) :<C-U>WintabsNext<CR>
nnoremap <silent> <Plug>(wintabs_previous) :<C-U>WintabsPrevious<CR>
nnoremap <silent> <Plug>(wintabs_close) :<C-U>WintabsClose<CR>
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
nnoremap <silent> <Plug>(wintabs_maximize) :<C-U>WintabsMaximize<CR>
nnoremap <silent> <Plug>(wintabs_refresh) :<C-U>WintabsRefresh<CR>

" commands
command! WintabsNext call wintabs#jump(1, 0)
command! WintabsPrevious call wintabs#jump(-1, 0)
command! WintabsClose call wintabs#close()
command! WintabsOnly call wintabs#only()
command! WintabsAll call wintabs#all()
command! WintabsCloseWindow call wintabs#close_window()
command! WintabsOnlyWindow call wintabs#only_window()
command! WintabsCloseVimtab call wintabs#close_vimtab()
command! WintabsOnlyVimtab call wintabs#only_vimtab()
command! -nargs=1 WintabsGo call wintabs#go(<q-args> + 0)
command! WintabsFirst call wintabs#go(1)
command! WintabsLast call wintabs#go(-1)
command! -nargs=1 WintabsMove call wintabs#move(<q-args> + 0)
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
call s:set('g:wintabs_autoclose_vimtab', 0)
call s:set('g:wintabs_ignored_filetypes', ['gitcommit', 'vundle', 'qf', 'vimfiler'])

" ui
call s:set('g:wintabs_ui_modified', ' +')
call s:set('g:wintabs_ui_readonly', ' -')
call s:set('g:wintabs_ui_sep_leftmost', ' ')
call s:set('g:wintabs_ui_sep_inbetween', '|')
call s:set('g:wintabs_ui_sep_rightmost', '|')
call s:set('g:wintabs_ui_active_left', ' ')
call s:set('g:wintabs_ui_active_right', ' ')

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

" init session
call wintabs#session#init()

" start wintabs
call wintabs#init()
