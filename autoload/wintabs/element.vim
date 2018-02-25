" get display width of element(s)
function! wintabs#element#len(var)
  return wintabs#memoize#call(function('s:len'), a:var)
endfunction

" get rendered text of element(s)
function! wintabs#element#render(var)
  return wintabs#memoize#call(function('s:render'), a:var)
endfunction

" use wintabs#element#len to slice element(s)
function! wintabs#element#slice(var, start, width)
  return wintabs#memoize#call(function('s:slice'), a:var, a:start, a:width)
endfunction

function! s:len(var)
  if type(a:var) == type('')
    return strdisplaywidth(a:var)
  endif

  if type(a:var) == type({})
    return wintabs#element#len(a:var.label)
  endif

  if type(a:var) == type([])
    let len = 0
    for element in a:var
      let len = len + wintabs#element#len(element)
    endfor
    return len
  endif

  return 0
endfunction

function! s:render(var)
  if type(a:var) == type('')
    return a:var
  endif

  if type(a:var) == type({})
    let text = a:var.label
    if !empty(a:var.highlight)
      let text = '%#'.a:var.highlight.'#'.text.'%##'
    endif
    if has('tablineat') && g:wintabs_display == 'tabline'
      if a:var.type == 'buffer'
        let text = '%'.a:var.number.'@wintabs#element#buffer_click@'.text.'%X'
      elseif a:var.type == 'tab'
        let text = '%'.a:var.number.'@wintabs#element#tab_click@'.text.'%X'
      elseif a:var.type == 'left_arrow'
        let text = '%@wintabs#element#left_arrow_click@'.text.'%X'
      elseif a:var.type == 'right_arrow'
        let text = '%@wintabs#element#right_arrow_click@'.text.'%X'
      endif
    else
      if a:var.type == 'tab'
        let text = '%'.a:var.number.'T'.text.'%T'
      endif
    endif
    return text
  endif

  if type(a:var) == type([])
    let text = ''
    for element in s:merge_higroup(a:var)
      let text = text.wintabs#element#render(element)
    endfor
    return text
  endif

  return ''
endfunction

function! s:slice(var, start, width)
  if type(a:var) == type('')
    let skip = ''
    let slice = ''
    for char in split(a:var, '.\zs')
      if wintabs#element#len(skip) < a:start
        let skip = skip.char
        let width = wintabs#element#len(skip) - a:start
        if width > 0
          for i in range(1, max([min([width, a:width]), 0]))
            let slice = slice.' '
          endfor
        endif
      elseif wintabs#element#len(slice.char) > a:width
        for i in range(1, max([a:width - wintabs#element#len(slice), 0]))
          let slice = slice.' '
        endfor
        return slice
      else
        let slice = slice.char
      endif
    endfor
    return slice
  endif

  if type(a:var) == type({})
    let element = copy(a:var)
    let element.label = wintabs#element#slice(element.label, a:start, a:width)
    return element
  endif

  if type(a:var) == type([])
    let skip = []
    let slice = []
    for element in a:var
      let skip_len = wintabs#element#len(skip)
      if skip_len < a:start
        call add(skip, element)
        if wintabs#element#len(skip) > a:start
          let start = a:start - skip_len
          call add(slice, wintabs#element#slice(element, start, a:width))
        endif
      else
        let width = a:width - wintabs#element#len(slice)
        if width <= 0
          return slice
        endif
        call add(slice, wintabs#element#slice(element, 0, width))
      endif
    endfor
    return slice
  endif

  return []
endfunction

" neovim click handler for buffers
function! wintabs#element#buffer_click(bufnr, click_count, button, modifiers)
  if a:button == 'l'
    execute 'silent! confirm buffer '.a:bufnr
  elseif a:button == 'm'
    execute 'silent! confirm buffer '.a:bufnr
    call wintabs#close()
  endif
endfunction

" neovim click handler for vimtabs
function! wintabs#element#tab_click(tabnr, click_count, button, modifiers)
  if a:button == 'l'
    execute 'tabnext '.a:tabnr
  elseif a:button == 'm'
    execute 'tabclose '.a:tabnr
  endif
endfunction

" neovim click handler for left arrow
function! wintabs#element#left_arrow_click(_, click_count, button, modifiers)
  if a:button == 'l'
    call wintabs#jump(-1, 0)
  endif
endfunction

" neovim click handler for right arrow
function! wintabs#element#right_arrow_click(_, click_count, button, modifiers)
  if a:button == 'l'
    call wintabs#jump(1, 0)
  endif
endfunction

" merge adjacent elements when they have the same highlight group
" this is a specific optimization to avoid E541 (too many elements)
function! s:merge_higroup(elements)
  if len(a:elements) < 2
    return a:elements
  endif

  let merged = [a:elements[0]]
  for i in range(1, len(a:elements) - 1)
    let prev = copy(merged[-1])
    let curr = copy(a:elements[i])
    if type(prev) == type({}) && type(curr) == type({}) &&
          \synIDtrans(hlID(prev.highlight)) == synIDtrans(hlID(curr.highlight))
      let highlight = prev.highlight
      let prev.highlight = ''
      let curr.highlight = ''
      let merged[-1] = {
            \'type': 'merged',
            \'label': wintabs#element#render(prev).wintabs#element#render(curr),
            \'highlight': highlight,
            \}
    else
      call add(merged, curr)
    endif
  endfor

  return merged
endfunction
