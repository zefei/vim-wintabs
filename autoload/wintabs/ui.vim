" generate tabline, very straight forward
function! wintabs#ui#get_tabline()
  let [spaceline, spaceline_len] = s:get_spaceline()
  let bufline = s:get_bufline(0)
  let line = s:truncate_line(0, bufline, &columns - spaceline_len)
  return line.'%='.spaceline
endfunction

" set statusline window by window
function! wintabs#ui#set_statusline()
  for window in range(1, winnr('$'))
    call setwinvar(window, '&statusline', '%!wintabs#ui#get_statusline('.window.')')
  endfor
endfunction

" generate statusline window by window
function! wintabs#ui#get_statusline(window)
  let bufline = s:get_bufline(a:window)
  let line = s:truncate_line(a:window, bufline, winwidth(a:window))

  " reseter is attached to detect stale status
  let reseter = '%{wintabs#ui#reset_statusline('.a:window.')}'
  return reseter.line
endfunction

" reset statusline
function! wintabs#ui#reset_statusline(window)
  " reset statusline if its assigned winnr is stale
  if a:window != winnr()
    call wintabs#ui#set_statusline()
  endif
  return ''
endfunction

" private functions below

" generate bufline per window
function! s:get_bufline(window)
  call wintabs#refresh_buflist(a:window)

  let line = g:wintabs_ui_sep_leftmost
  let seplen = len(g:wintabs_ui_sep_inbetween)
  let active_start = 0
  let active_end = 0
  let active_higroup_len = 0

  for buffer in wintabs#getwinvar(a:window, 'wintabs_buflist', [])
    " get buffer name and normalize
    let name = fnamemodify(bufname(buffer), ':t')
    let name = substitute(name, '%', '%%', 'g')
    if name == ''
      let name = '[No Name]'
    endif

    if getbufvar(buffer, '&readonly', '')
      let name = name.g:wintabs_ui_readonly
    elseif getbufvar(buffer, '&modified', '')
      let name = name.g:wintabs_ui_modified
    endif

    let name = ' '.name.' '

    " highlight current buffer
    if buffer == winbufnr(a:window)
      " remove last 'inbetween' separator or 'leftmost' separator
      if line == g:wintabs_ui_sep_leftmost
        let line = ''
      else
        let line = line[:-(seplen+1)]
      endif

      " add active tab markers and highlight group
      let name = g:wintabs_ui_active_left.name.g:wintabs_ui_active_right
      let name = '%#'.g:wintabs_ui_active_higroup.'#'.name.'%##'

      " save position of current buffer
      let active_start = len(line)
      let active_end = len(line.name)
      let active_higroup_len = len('%##%##'.g:wintabs_ui_active_higroup)
    else
      let name = name.g:wintabs_ui_sep_inbetween
    endif

    let line = line.name
  endfor

  if line == g:wintabs_ui_sep_leftmost
    " remove separators if buflist is empty
    let line = ''
  elseif line[-3:] != '%##'
    " change last 'inbetween' separator to 'rightmost'
    let line = line[:-(seplen+1)].g:wintabs_ui_sep_rightmost
  endif

  return [line, active_start, active_end, active_higroup_len]
endfunction

" truncate bufline
function! s:truncate_line(window, bufline, width)
  let [line, active_start, active_end, active_higroup_len] = a:bufline

  " load line_start from saved value
  let line_start = wintabs#getwinvar(a:window, 'wintabs_bufline_start', 0)

  " inflate width by length of higroup markers
  let inflated_width = a:width + active_higroup_len
  let width = inflated_width

  " arrows are added to indicate truncation
  let left_arrow = 0
  let right_arrow = 0
  let left_arrow_len = len(g:wintabs_ui_arrow_left)
  let right_arrow_len = len(g:wintabs_ui_arrow_right)

  " adjust line_start and width to accommodate actie buffer and arrows
  " 3 passes are needed to satisfy enough constraints
  for i in range(3)
    " line_start <= active_start < active_end <= line_start + width
    if active_start < active_end
      if line_start > active_start
        let line_start = active_start
      endif
      if active_end > line_start + width
        let line_start = active_end - width
      endif
    endif

    " check if left arrow is needed
    if !left_arrow && line_start > 0
      let left_arrow = 1
      let width -= left_arrow_len
    endif

    " check if right arrow is needed
    if !right_arrow && line_start + width < len(line)
      let right_arrow = 1
      let width -= right_arrow_len
    elseif right_arrow && line_start + width >= len(line)
      let right_arrow = 0
      let width += right_arrow_len
    endif
  endfor

  " if it's at the end of bufline, try to expand as much as possible
  if left_arrow && !right_arrow
    let width = inflated_width
    let line_start = len(line) - width
    if line_start <= 0
      let left_arrow = 0
      let line_start = 0
    else
      let left_arrow = 1
      let line_start += left_arrow_len
    endif
  endif

  " save line_start
  call setwinvar(a:window, 'wintabs_bufline_start', line_start)

  " final assembly
  let left = left_arrow ? g:wintabs_ui_arrow_left : ''
  let right = right_arrow ? g:wintabs_ui_arrow_right : ''
  let line = left.strpart(line, line_start, width).right

  return line
endfunction

" generate space (vim tabs) line
function! s:get_spaceline()
  " return empty line if there is only one space (vim tab)
  let spaces = tabpagenr('$')
  if spaces == 1
    return ['', 0]
  endif

  let line = g:wintabs_ui_sep_spaceline
  let length = 1
  for tab in range(1, spaces)
    " get and normalize space name
    let name = ' '.tab.' '
    let length += len(name)

    " highlight current space
    if tab == tabpagenr()
      let name = '%#'.g:wintabs_ui_active_higroup.'#'.name.'%##'
    endif

    " make name clickable
    let name = '%'.tab.'T'.name.'%T'

    let line = line.name
  endfor

  return [line, length]
endfunction
