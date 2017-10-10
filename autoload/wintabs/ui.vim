"" generate tabline, very straight forward
function! wintabs#ui#get_tabline()
  if g:wintabs_use_powerline
    let [spaceline, spaceline_len] = s:get_spaceline_powerline()
    let bufline = s:get_bufline_powerline(0)
      let line = bufline[0]
  else
    let [spaceline, spaceline_len] = s:get_spaceline()
    let bufline = s:get_bufline(0)
    let line = s:truncate_line(0, bufline, &columns - spaceline_len)
  endif
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

    if getbufvar(buffer, '&readonly')
      let name = name.g:wintabs_ui_readonly
    elseif getbufvar(buffer, '&modified')
      let name = name.g:wintabs_ui_modified
    endif

    let name = substitute(g:wintabs_ui_buffer_name_format, "%t", name, "g")
    let name = substitute(name, "%n", buffer, "g")
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
      let name = '%#'.g:wintabs_ui_active_buffer_higroup.'#'.name.'%##'

      " save position of current buffer
      let active_start = len(line)
      let active_end = len(line.name)
      let active_higroup_len = len('%##%##'.g:wintabs_ui_active_buffer_higroup)
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

" generate bufline per window with powerline fonts
function! s:get_bufline_powerline(window)
  call wintabs#refresh_buflist(a:window)

  let line = ''
  let seplen = len(g:wintabs_ui_powerline_sep_inbetween_buffer.'%##')
  let active_start = 0
  let active_end = 0
  let active_higroup_len = 0

  let l:bufferlist = wintabs#getwinvar(a:window, 'wintabs_buflist', [])
  for i in range(0, len(l:bufferlist)-1)
    " get buffer name and normalize
    let buffer = l:bufferlist[i]
    let name = fnamemodify(bufname(buffer), ':t')
    let name = substitute(name, '%', '%%', 'g')
    if name == ''
      let name = '[No Name]'
    endif

    let changed = 0
    if getbufvar(buffer, '&readonly')
      let name = name.g:wintabs_ui_readonly
    elseif getbufvar(buffer, '&modified')
      let name = name.g:wintabs_ui_modified
      let changed = 1
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
      let left_sep_higroup = 'WintabsPowerlineSepActiveBufferLeft'
      let right_sep_higroup = 'WintabsPowerlineSepActiveBufferRight'
      let active_buffer_higroup = g:wintabs_ui_active_buffer_higroup
      if changed
          let left_sep_higroup = 'WintabsPowerlineSepActiveBufferChangedLeft'
          let right_sep_higroup = 'WintabsPowerlineSepActiveBufferChangedRight'
          let active_buffer_higroup = g:wintabs_ui_active_buffer_changed_higroup
      endif

      "if active buffer is first buffer dont use the left seperator
      if line == ''
        let left_sep = ''
      else
        let left_sep = '%#'.left_sep_higroup.'#'.g:wintabs_ui_powerline_sep_active_buffer_left.'%##'
      endif
      "if active is the last buffer right seperator needs to use normal background
      if i == len(l:bufferlist)-1
        if changed == 0
          let right_sep_higroup = 'WintabsPowerlineSepActiveBufferRightRightmost'
        endif
      endif
      let right_sep = '%#'.right_sep_higroup.'#'.g:wintabs_ui_powerline_sep_active_buffer_right.'%##'
      let name = left_sep.'%#'.active_buffer_higroup.'#'.name.'%##'.right_sep

      " save position of current buffer
      let active_start = len(line)
      let active_end = len(line.name)
      let active_higroup_len = len('%##%##%##%##%##%##'.g:wintabs_ui_active_buffer_higroup.left_sep_higroup.right_sep_higroup)
    else
      if i == len(l:bufferlist)-1
        let name = '%#'.g:wintabs_ui_inactive_buffer_higroup.'#'.name.'%##'.'%#WintabsPowerlineBufferRightmost#'.g:wintabs_ui_powerline_sep_rightmost_buffer.'%##'
      else
        let name = '%#'.g:wintabs_ui_inactive_buffer_higroup.'#'.name.g:wintabs_ui_powerline_sep_inbetween_buffer.'%##'
      endif
    endif

    let line = line.name
  endfor

  if line == g:wintabs_ui_sep_leftmost
    " remove separators if buflist is empty
    let line = ''
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
      let width -= left_arrow_len
    endif
  endif

  " if active tab is longer than width, truncate inside active tab
  if active_end - active_start > width
    let line_start = active_start
    " re-assess lefe arrow since this is an edge case
    if left_arrow && line_start == 0
      let left_arrow = 0
      let width += left_arrow_len
    endif
    " truncate line and leave enough space for markers
    let endline = '..'.g:wintabs_ui_active_right.'%##'
    let line = strpart(line, 0, line_start + width - len(endline)).endline
  endif

  " save line_start
  call setwinvar(a:window, 'wintabs_bufline_start', line_start)

  " final assembly
  let left = left_arrow ? g:wintabs_ui_arrow_left : ''
  let right = right_arrow ? g:wintabs_ui_arrow_right : ''
  let line = left.strpart(line, line_start, width).right

  return line
endfunction

function! s:get_tab_name(n)
  let title = ''
  let s:taboo = get(g:, 'loaded_taboo', 0)
  if s:taboo
    let title = TabooTabTitle(a:n)
  endif

  if empty(title) && exists('*gettabvar')
    let title = gettabvar(a:n, 'title')
  endif

  if empty(title)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let title = bufname(buflist[winnr - 1])
    if empty(title)
      let title = '[No Name]'
    else
      let title = split(title, "/")[-1]
    endif
    if getbufvar(buflist[winnr - 1], '&modified')
      let title = title.g:wintabs_ui_modified
    endif
  endif

  let title = substitute(g:wintabs_ui_vimtab_name_format, "%t", title, "g")
  let title = substitute(title, "%n", a:n, "g")

  return title
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
    " get tab name
    let name = s:get_tab_name(tab)

    " highlight current space
    if tab == tabpagenr()
      let name = g:wintabs_ui_active_vimtab_left.name.g:wintabs_ui_active_vimtab_right
      let length += len(name)
      let name = '%#'.g:wintabs_ui_active_buffer_higroup.'#'.name.'%##'
    else
      let name = ' '.name.' '
      let length += len(name)
    endif

    " make name clickable
    let name = '%'.tab.'T'.name.'%T'

    let line = line.name
  endfor

  return [line, length]
endfunction

" generate space (vim tabs) line (with powerline_font)
function! s:get_spaceline_powerline()
  " return empty line if there is only one space (vim tab)
  let spaces = tabpagenr('$')
  if spaces == 1
    return ['', 0]
  endif

  let line = ''
  let length = 0
  let active_tab_left = 0
  for tab in range(1, spaces)
    " get tab name
    let name = s:get_tab_name(tab)

    " highlight current space
    if tab == tabpagenr()
      let active_tab_left = 1
      if tab == spaces
        let right_sep = ''
      else
        let right_sep = '%#WintabsPowerlineSepActiveTabRight#'.g:wintabs_ui_powerline_sep_active_tab_right.'%##'
      endif
      "if active is the last buffer right seperator needs to use normal background
      if tab == 1
        let left_sep = '%#WintabsPowerlineSepActiveTabLeftLeftmost#'.g:wintabs_ui_powerline_sep_active_tab_left.'%##'
      else
        let left_sep = '%#WintabsPowerlineSepActiveTabLeft#'.g:wintabs_ui_powerline_sep_active_tab_left.'%##'
      endif
      let length += len(g:wintabs_ui_powerline_sep_active_tab_left.name.g:wintabs_ui_powerline_sep_active_tab_right)
      let name = '%#'.g:wintabs_ui_active_tab_higroup.'# '.name.' %##'
      let name = left_sep.name.right_sep
    else
      if length == 0 || active_tab_left == 1
        if active_tab_left == 1
          let active_tab_left = 0
          let name = '%#'.g:wintabs_ui_inactive_tab_higroup.'# '.name.' %##'
        else
          let name = '%#WintabsPowerlineTabLeftmost#'.g:wintabs_ui_powerline_sep_leftmost_tab.'%##%#'.g:wintabs_ui_inactive_tab_higroup.'# '.name.' %##'
        endif
        let length += len(name)
      else
        let name = '%#'.g:wintabs_ui_inactive_tab_higroup.'#'.g:wintabs_ui_powerline_sep_inbetween_tab.' '.name.' '.'%##'
        let length += len(name)
      endif
    endif

    " make name clickable
    let name = '%'.tab.'T'.name.'%T'

    let line = line.name
  endfor

  return [line, length]
endfunction
