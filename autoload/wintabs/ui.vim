" generate tabline, very straight forward
function! wintabs#ui#get_tabline()
  let spaceline = s:get_spaceline()
  let bufline = s:truncate_line(
        \0,
        \s:get_bufline(0),
        \&columns - wintabs#element#len(spaceline),
        \)
  let padding = g:wintabs_renderers.padding(
        \&columns - wintabs#element#len(bufline) - wintabs#element#len(spaceline)
        \)
  return wintabs#element#render([bufline, padding, spaceline])
endfunction

" set statusline window by window
function! wintabs#ui#set_statusline()
  for window in range(1, winnr('$'))
    call setwinvar(window, '&statusline', '%!wintabs#ui#get_statusline('.window.')')
  endfor
endfunction

" generate statusline window by window
function! wintabs#ui#get_statusline(window)
  let bufline = s:truncate_line(
        \a:window,
        \s:get_bufline(a:window),
        \winwidth(a:window)
        \)
  let padding = g:wintabs_renderers.padding(
        \winwidth(a:window) - wintabs#element#len(bufline)
        \)
  " reseter is attached to detect stale status
  let reseter = '%{wintabs#ui#reset_statusline('.a:window.')}'
  return wintabs#element#render([reseter, bufline, padding])
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
  let buffers = copy(wintabs#getwinvar(a:window, 'wintabs_buflist', []))
  call add(buffers, winbufnr(a:window))
  let bufnames = map(copy(buffers), "bufname(v:val)")
  let modified = map(copy(buffers), "getbufvar(v:val, '&modified')")
  let bufline = wintabs#memoize#call(
        \function('s:get_bufline_non_memoized'),
        \a:window,
        \buffers,
        \bufnames,
        \modified,
        \a:window == winnr(),
        \)
  call wintabs#session#save(tabpagenr(), a:window)
  return bufline
endfunction

function! s:get_bufline_non_memoized(window, ...)
  call wintabs#refresh_buflist(a:window)

  let line = []
  let active_start = 0
  let active_end = 0
  let i = 0
  let buffers = wintabs#getwinvar(a:window, 'wintabs_buflist', [])
  let active_index = index(buffers, winbufnr(a:window))

  for buffer in buffers
    let is_active = i == active_index
    let is_next_active = i == active_index - 1
    let has_focus = g:wintabs_display == 'tabline'
          \|| (g:wintabs_display == 'statusline' && a:window == winnr())

    if i == 0
      if is_active
        let active_start = wintabs#element#len(line)
      endif

      let element = g:wintabs_renderers.buffer_sep({
            \'is_leftmost': 1,
            \'is_rightmost': 0,
            \'is_left': active_index >= 0,
            \'is_right': 0,
            \'is_active': is_active && has_focus,
            \})
      let element.type = 'sep'
      call add(line, element)
    endif

    let element = g:wintabs_renderers.buffer(buffer, {
          \'is_leftmost': 0,
          \'is_rightmost': i == len(buffers) - 1,
          \'is_left': active_index >= 0 && i < active_index,
          \'is_right': active_index >= 0 && i > active_index,
          \'is_active': is_active && has_focus,
          \})
    let element.type = 'buffer'
    let element.number = buffer
    call add(line, element)

    if is_next_active
      let active_start = wintabs#element#len(line)
    endif

    let element = g:wintabs_renderers.buffer_sep({
          \'is_leftmost': 0,
          \'is_rightmost': i == len(buffers) - 1,
          \'is_left': active_index >= 0 && i < active_index,
          \'is_right': active_index >= 0 && i >= active_index,
          \'is_active': (is_active || is_next_active) && has_focus,
          \})
    let element.type = 'sep'
    call add(line, element)

    if is_active
      let active_end = wintabs#element#len(line)
    endif

    let i = i + 1
  endfor

  return [line, active_start, active_end]
endfunction

" truncate bufline
function! s:truncate_line(window, bufline, width)
  let [elements, line_start] = wintabs#memoize#call(
        \function('s:truncate_line_non_memoized'),
        \a:window,
        \a:bufline,
        \a:width,
        \wintabs#getwinvar(a:window, 'wintabs_bufline_start', 0)
        \)
  call setwinvar(a:window, 'wintabs_bufline_start', line_start)
  return elements
endfunction

function! s:truncate_line_non_memoized(window, bufline, width, ...)
  let [line, active_start, active_end] = a:bufline
  let line_len = wintabs#element#len(line)

  " load line_start from saved value
  let line_start = wintabs#getwinvar(a:window, 'wintabs_bufline_start', 0)
  let width = a:width

  " arrows are added to indicate truncation
  let has_left_arrow = 0
  let has_right_arrow = 0
  let left_arrow = g:wintabs_renderers.left_arrow()
  let right_arrow = g:wintabs_renderers.right_arrow()
  let left_arrow_len = wintabs#element#len(left_arrow)
  let right_arrow_len = wintabs#element#len(right_arrow)

  " adjust line_start and width to accommodate active buffer and arrows
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
    if !has_left_arrow && line_start > 0
      let has_left_arrow = 1
      let width -= left_arrow_len
    endif

    " check if right arrow is needed
    if !has_right_arrow && line_start + width < line_len
      let has_right_arrow = 1
      let width -= right_arrow_len
    elseif has_right_arrow && line_start + width >= line_len
      let has_right_arrow = 0
      let width += right_arrow_len
    endif
  endfor

  " if it's at the end of bufline, try to expand as much as possible
  if has_left_arrow && !has_right_arrow
    let width = a:width
    let line_start = line_len - width
    if line_start <= 0
      let has_left_arrow = 0
      let line_start = 0
    else
      let has_left_arrow = 1
      let line_start += left_arrow_len
      let width -= left_arrow_len
    endif
  endif

  " if active tab is longer than width, align to its start
  if active_end - active_start > width
    let line_start = active_start
    " re-assess lefe arrow since this is an edge case
    if has_left_arrow && line_start == 0
      let has_left_arrow = 0
      let width += left_arrow_len
    endif
  endif

  " save line_start
  call setwinvar(a:window, 'wintabs_bufline_start', line_start)

  " final assembly
  let elements = []
  if has_left_arrow
    call add(elements, left_arrow)
  endif
  call add(elements, wintabs#element#slice(line, line_start, width))
  if has_right_arrow
    call add(elements, right_arrow)
  endif
  return [elements, line_start]
endfunction

" generate space (vim tabs) line
function! s:get_spaceline()
  " return empty line if there is only one space (vim tab)
  let spaces = tabpagenr('$')
  if spaces == 1
    return ['', 0]
  endif

  let line = [g:wintabs_renderers.line_sep()]
  let active_index = tabpagenr()

  for tab in range(1, spaces)
    let is_active = tab == active_index
    let is_next_active = tab == active_index - 1

    if tab == 1
      let element = g:wintabs_renderers.tab_sep({
            \'is_leftmost': 1,
            \'is_rightmost': 0,
            \'is_left': active_index >= 0,
            \'is_right': 0,
            \'is_active': is_active,
            \})
      let element.type = 'sep'
      call add(line, element)
    endif

    let element = g:wintabs_renderers.tab(tab, {
          \'is_leftmost': 0,
          \'is_rightmost': tab == spaces,
          \'is_left': active_index >= 0 && tab < active_index,
          \'is_right': active_index >= 0 && tab > active_index,
          \'is_active': is_active,
          \})
    let element.type = 'tab'
    let element.number = tab
    call add(line, element)

    let element = g:wintabs_renderers.tab_sep({
          \'is_leftmost': 0,
          \'is_rightmost': tab == spaces,
          \'is_left': active_index >= 0 && tab < active_index,
          \'is_right': active_index >= 0 && tab >= active_index,
          \'is_active': is_active || is_next_active,
          \})
    let element.type = 'sep'
    call add(line, element)
  endfor

  return line
endfunction
