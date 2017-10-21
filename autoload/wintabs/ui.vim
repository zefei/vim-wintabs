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

  let active_start = 0
  let active_end = 0
  let active_higroup_len = 0

  let line = ''
  let i = 0
  let buffers = wintabs#getwinvar(a:window, 'wintabs_buflist', [])
  let active_index = index(buffers, winbufnr(a:window))

  for buffer in buffers
    let is_active = i == active_index
    let is_next_active = i == active_index - 1

    if i == 0
      if is_active
        let active_start = len(line)
        let line = line.'%#'.g:wintabs_ui_active_higroup.'#'
      endif

      let line = line.g:wintabs_renderers.buffer_sep({
            \'is_leftmost': 1,
            \'is_rightmost': 0,
            \'is_left': active_index >= 0,
            \'is_right': 0,
            \'is_active': is_active,
            \})
    endif

    let line = line.g:wintabs_renderers.buffer(buffer, {
          \'is_leftmost': 0,
          \'is_rightmost': i == len(buffers) - 1,
          \'is_left': active_index >= 0 && i < active_index,
          \'is_right': active_index >= 0 && i > active_index,
          \'is_active': is_active,
          \})

    if is_next_active
      let active_start = len(line)
      let line = line.'%#'.g:wintabs_ui_active_higroup.'#'
    endif

    let line = line.g:wintabs_renderers.buffer_sep({
          \'is_leftmost': 0,
          \'is_rightmost': i == len(buffers) - 1,
          \'is_left': active_index >= 0 && i < active_index,
          \'is_right': active_index >= 0 && i >= active_index,
          \'is_active': is_active || is_next_active,
          \})

    if is_active
      let line = line.'%##'
      let active_end = len(line)
      let active_higroup_len = len('%##%##'.g:wintabs_ui_active_higroup)
    endif

    let i = i + 1
  endfor

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
  let left_arrow_label = g:wintabs_renderers.left_arrow()
  let right_arrow_label = g:wintabs_renderers.right_arrow()
  let left_arrow_len = len(left_arrow_label)
  let right_arrow_len = len(right_arrow_label)

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
  let left = left_arrow ? left_arrow_label : ''
  let right = right_arrow ? right_arrow_label : ''
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

  let line = ''
  let active_index = tabpagenr()
  let length = 0

  for tab in range(1, spaces)
    let is_active = tab == active_index
    let is_next_active = tab == active_index - 1

    if tab == 1
      if is_active
        let line = line.'%#'.g:wintabs_ui_active_higroup.'#'
      endif

      let sep = g:wintabs_renderers.tab_sep({
            \'is_leftmost': 1,
            \'is_rightmost': 0,
            \'is_left': active_index >= 0,
            \'is_right': 0,
            \'is_active': is_active,
            \})
      let line = line.sep
      let length = length + len(sep)
    endif

    let name = g:wintabs_renderers.tab(tab, {
          \'is_leftmost': 0,
          \'is_rightmost': tab == spaces,
          \'is_left': active_index >= 0 && tab < active_index,
          \'is_right': active_index >= 0 && tab > active_index,
          \'is_active': is_active,
          \})
    let line = line.'%'.tab.'T'.name.'%T'
    let length = length + len(name)

    if is_next_active
      let line = line.'%#'.g:wintabs_ui_active_higroup.'#'
    endif

    let sep = g:wintabs_renderers.tab_sep({
          \'is_leftmost': 0,
          \'is_rightmost': tab == spaces,
          \'is_left': active_index >= 0 && tab < active_index,
          \'is_right': active_index >= 0 && tab >= active_index,
          \'is_active': is_active || is_next_active,
          \})
    let line = line.sep
    let length = length + len(sep)

    if is_active
      let line = line.'%##'
    endif
  endfor

  return [line, length]
endfunction
