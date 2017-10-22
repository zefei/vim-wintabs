" get display width of element(s)
function! wintabs#element#len(var)
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

" get rendered text of element(s)
function! wintabs#element#render(var)
  if type(a:var) == type('')
    return a:var
  endif

  if type(a:var) == type({})
    let text = a:var.label
    if !empty(a:var.highlight)
      let text = '%#'.a:var.highlight.'#'.text.'%##'
    endif
    if (a:var.type == 'tab')
      let text = '%'.a:var.number.'T'.text.'%T'
    endif
    return text
  endif

  if type(a:var) == type([])
    let text = ''
    for element in a:var
      let text = text.wintabs#element#render(element)
    endfor
    return text
  endif

  return ''
endfunction

" use wintabs#element#len to slice element(s)
function! wintabs#element#slice(var, start, width)
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
