if v:version >= 704
  function! wintabs#getwinvar(winnr, key, def)
    return getwinvar(a:winnr, a:key, a:def)
  endfunction
  function! wintabs#getbufvar(buf, key, def)
    return getbufvar(a:buf, a:key, a:def)
  endfunction
else
  function! wintabs#getwinvar(winnr, key, def)
    let winvals = getwinvar(a:winnr, '')
    return get(winvals, a:key, a:def)
  endfunction
  function! wintabs#getbufvar(buf, key, def)
    let bufvals = getbufvar(a:buf, '')
    return get(bufvals, a:key, a:def)
  endfunction
endif

" jump to next/previous tab
" next tab if offset == 1, previous tab if offset == -1
" use confirm dialog if confim isn't 0
function! wintabs#jump(offset, confirm)
  call wintabs#refresh_buflist(0)

  let [n, found] = s:current_tab()

  " if current window contains no tabs, do nothing
  if n < 0
    return
  endif

  " if substitute is used, use it as previous tab
  let offset = a:offset
  if !found
    let offset = offset < 0 ? 0 : offset
  endif

  " jump
  let size = len(w:wintabs_buflist)
  let n = (n + offset) % size
  let n = n < 0 ? n + size : n
  call s:switch_tab(n, a:confirm)
endfunction

" close current tab
function! wintabs#close()
  call wintabs#refresh_buflist(0)

  let size = len(w:wintabs_buflist)
  let buffer = bufnr('%')
  let [n, found] = s:current_tab()
  let close_window = 0

  " close window if:
  " autoclose is 1 or 2 && no tab is listed
  " autoclose is 2 && only current tab is listed
  " otherwise, switch to previous tab or a new buffer
  if size == 0
    if g:wintabs_autoclose == 0
      let switch_to = -1
    else
      let close_window = 1
    endif
  elseif size == 1 && found
    if g:wintabs_autoclose != 2
      let switch_to = -1
    else
      let close_window = 1
    endif
  else
    if found
      let switch_to = n == 0 ? 1 : n - 1
    else
      let switch_to = n
    endif
  endif

  if close_window
    call s:close_window()
  else
    call s:switch_tab(switch_to, 1)

    " only remove buffer that is unmodifed
    " buffer remains modified if confirm dialog is canceled
    if !wintabs#getbufvar(buffer, '&modified', '')
      call filter(w:wintabs_buflist, 'v:val != '.buffer)
    endif
  endif
endfunction

" close all but current tab
function! wintabs#only()
  call wintabs#refresh_buflist(0)

  let buflist = []
  let modified = 0

  " keep modified tabs and current buffer
  for buffer in w:wintabs_buflist
    if buffer == bufnr('%')
      call add(buflist, buffer)
    elseif wintabs#getbufvar(buffer, '&modified', '')
      call add(buflist, buffer)
      let modified = 1
    endif
  endfor

  if modified
    echoerr 'Some tabs contain changes'
  endif

  let w:wintabs_buflist = buflist
  call wintabs#init()
endfunction

" open all wintabs inside current vim tab in current window
function! wintabs#all()
  call wintabs#refresh_buflist(0)

  for window in range(1, winnr('$'))
    if window == winnr()
      continue
    endif

    call wintabs#refresh_buflist(window)

    for buffer in wintabs#getwinvar(window, 'wintabs_buflist', [])
      if index(w:wintabs_buflist, buffer) == -1
        call add(w:wintabs_buflist, buffer)
      endif
    endfor
  endfor

  call wintabs#init()
endfunction

" close current window
function! wintabs#close_window()
  let w:wintabs_closing = 1
  let s:modified = 0

  call s:close_tabs_window()
  call wintabs#init()

  if s:modified
    echoerr 'Some tabs contain changes'
  endif
endfunction

" close all but current window
function! wintabs#only_window()
  let window = winnr()
  windo let w:wintabs_closing = winnr() != window
  let s:modified = 0

  windo call s:close_tabs_window()
  call wintabs#init()

  if s:modified
    echoerr 'Some tabs contain changes'
  endif
endfunction

" close current vim tab
function! wintabs#close_vimtab()
  " set autoclose so that tab is closed after all windows are closed
  let autoclose = g:wintabs_autoclose_vimtab
  let g:wintabs_autoclose_vimtab = 1

  windo let w:wintabs_closing = 1
  let s:modified = 0

  windo call s:close_tabs_window()
  call wintabs#init()

  if s:modified
    echoerr 'Some tabs contain changes'
  endif

  " reset autoclose
  let g:wintabs_autoclose_vimtab = autoclose
endfunction

" close all but current vim tab
function! wintabs#only_vimtab()
  " set autoclose so that tab is closed after all windows are closed
  let autoclose = g:wintabs_autoclose_vimtab
  let g:wintabs_autoclose_vimtab = 1

  let tabpage = tabpagenr()
  tabdo windo let w:wintabs_closing = tabpagenr() != tabpage
  let s:modified = 0

  tabdo windo call s:close_tabs_window()
  call wintabs#init()

  if s:modified
    echoerr 'Some tabs contain changes'
  endif

  " reset autoclose
  let g:wintabs_autoclose_vimtab = autoclose
endfunction

" go to nth tab
function! wintabs#go(n)
  call wintabs#refresh_buflist(0)

  let size = len(w:wintabs_buflist)

  " positive n needs -1 since n is ordinal number not index number
  " negative n means reverse index
  let n = a:n > 0 ? a:n - 1 : size + a:n

  " if n is out of range, do nothing
  if n < 0 || n >= size
    return
  endif

  call s:switch_tab(n, 0)
endfunction

" move the current tab by n tabs
function! wintabs#move(n)
  call wintabs#refresh_buflist(0)

  " do nothing if current tab isn't listed
  let buffer = bufnr('%')
  let pos = index(w:wintabs_buflist, buffer)
  if pos == -1
    return
  endif

  " get new position, clamp at boundary
  let size = len(w:wintabs_buflist)
  let new_pos = pos + a:n
  if new_pos < 0
    let new_pos = 0
  endif
  if new_pos >= size
    let new_pos = size - 1
  endif

  " move
  call remove(w:wintabs_buflist, pos)
  call insert(w:wintabs_buflist, buffer, new_pos)

  call wintabs#init()
endfunction

" move the current split window to its own Vim tab
function! wintabs#maximize()
  " do nothing if current Vim tab has only one window
  if winnr('$') == 1
    return
  endif

  call wintabs#refresh_buflist(0)

  let buflist = w:wintabs_buflist
  execute "normal! \<C-W>T"
  let w:wintabs_buflist = buflist

  call wintabs#init()
endfunction

" execute cmd for each tab
function! wintabs#do(cmd)
  call wintabs#refresh_buflist(0)

  for buffer in copy(w:wintabs_buflist)
    execute 'buffer! '.buffer
    execute a:cmd
  endfor
endfunction

" set tabline/statusline
function! wintabs#init()
  if g:wintabs_display == 'tabline'
    " disable gui tabline
    if has('gui_running')
      set guioptions-=e
    endif

    set showtabline=2
    set tabline=%!wintabs#ui#get_tabline()
  end

  if g:wintabs_display == 'statusline'
    set laststatus=2

    " statusline needs constant reset to test for active window
    augroup wintabs_set_statusline
      autocmd!
      autocmd BufWinEnter,WinEnter,VimEnter * call wintabs#ui#set_statusline()
    augroup END
    call wintabs#ui#set_statusline()
  else
    augroup wintabs_set_statusline
      autocmd!
    augroup END
  endif
endfunction

" refresh buffer list
function! wintabs#refresh_buflist(window)
  let window = a:window == 0 ? winnr() : a:window

  " load buflist from saved value
  let buflist = wintabs#getwinvar(window, 'wintabs_buflist', [])

  " remove stale bufs
  call filter(buflist, 's:buflisted(v:val)')

  " add current buf
  let current_buffer = winbufnr(window)
  if index(buflist, current_buffer) == -1 && s:buflisted(current_buffer)
    call add(buflist, current_buffer)
  endif

  " save buflist
  call setwinvar(window, 'wintabs_buflist', buflist)

  " save this to session
  call wintabs#session#save(tabpagenr(), window)
endfunction

" private functions below

" buffers listed as wintabs are
" buflisted()
" not ignored by g:wintabs_ignored_filetypes
" not empty: no buffer name and not modified
function! s:buflisted(buffer)
  let filetype = wintabs#getbufvar(a:buffer, '&filetype', '')
  let ignored = index(g:wintabs_ignored_filetypes, filetype) != -1
  let empty = bufname(a:buffer) == '' && !wintabs#getbufvar(a:buffer, '&modified', '')
  return buflisted(a:buffer) && !ignored && !empty
endfunction

" get current tab or a sensible substitute
" returns [n, found]: n is tab's ordinal, found is 0 if substitute is used
" returns [-1, 0] if current window contains no tabs
function! s:current_tab()
  " if there is no tab, return -1
  if len(w:wintabs_buflist) == 0
    return [-1, 0]
  endif

  let buffer = bufnr('%')

  " if % is unlisted, use #
  if !s:buflisted(buffer)
    let buffer = bufnr('#')
  endif

  let n = index(w:wintabs_buflist, buffer)

  " if no such tab, use last tab
  if n == -1
    let n = len(w:wintabs_buflist) - 1
    let found = 0
  else
    let found = buffer == bufnr('%')
  endif

  return [n, found]
endfunction

" switch to nth tab, or create a new tab if n < 0
" do nothing if n >= number of tabs
" use confirm dialog if confirm isn't 0
function! s:switch_tab(n, confirm)
  " do nothing if n >= size
  if a:n >= len(w:wintabs_buflist)
    return
  endif

  " set nohidden to trigger confirm behavior
  let hidden = &hidden
  let &hidden = 0

  if a:n < 0
    execute a:confirm ? 'silent! confirm enew' : 'enew!'
  else
    let buffer = w:wintabs_buflist[a:n]
    execute a:confirm ? 'silent! confirm buffer '.buffer : 'buffer! '.buffer
  endif

  " restore hidden
  let &hidden = hidden
endfunction

" close current window depending on g:wintabs_autoclose_vimtab
" assuming no open tabs
function! s:close_window()
  " don't close if this is the last window and tab autoclose is off
  if winnr('$') > 1 || g:wintabs_autoclose_vimtab
    confirm close
  else
    let w:wintabs_buflist = []
    call s:switch_tab(-1, 1)
  endif
endfunction

" close all tabs in current window and window itself
function! s:close_tabs_window()
  " if window doesn't set wintabs_closing, do nothing
  if !wintabs#getwinvar(0, 'wintabs_closing', '')
    return
  endif
  let w:wintabs_closing = 0

  call wintabs#refresh_buflist(0)

  let buflist = []
  let modified = 0

  " keep modified tabs
  for buffer in w:wintabs_buflist
    if wintabs#getbufvar(buffer, '&modified', '')
      call add(buflist, buffer)
      let modified = 1
    endif
  endfor

  if modified
    let s:modified = 1
    let w:wintabs_buflist = buflist

    " if current buffer should be closed (not modified), switch to first tab
    if !wintabs#getbufvar(bufnr('%'), '&modified', '')
      call s:switch_tab(0, 0)
    endif
  else
    call s:close_window()
  endif
endfunction
