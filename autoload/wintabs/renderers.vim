function! wintabs#renderers#bufname(bufnr)
  let name = fnamemodify(bufname(a:bufnr), ':t')
  let name = substitute(name, '%', '%%', 'g')
  if empty(name)
    let name = '[No Name]'
  endif
  if getbufvar(a:bufnr, '&readonly')
    let name = name.g:wintabs_ui_readonly
  elseif getbufvar(a:bufnr, '&modified')
    let name = name.g:wintabs_ui_modified
  endif
  return name
endfunction

function! wintabs#renderers#buffer(bufnr, config)
  let name = wintabs#renderers#bufname(a:bufnr)
  let name = substitute(g:wintabs_ui_buffer_name_format, "%t", name, "g")
  let name = substitute(name, "%n", a:bufnr, "g")
  return name
endfunction

function! wintabs#renderers#buffer_sep(config)
  if a:config.is_active && a:config.is_left
    return g:wintabs_ui_active_left
  endif
  if a:config.is_active && a:config.is_right
    return g:wintabs_ui_active_right
  endif
  if a:config.is_leftmost
    return g:wintabs_ui_sep_leftmost
  endif
  if a:config.is_rightmost
    return g:wintabs_ui_sep_rightmost
  endif
  return g:wintabs_ui_sep_inbetween
endfunction

function! wintabs#renderers#tab(tabnr, config)
  let title = ''
  if get(g:, 'loaded_taboo', 0)
    let title = TabooTabTitle(a:tabnr)
  endif

  if empty(title) && exists('*gettabvar')
    let title = gettabvar(a:tabnr, 'title')
  endif

  if empty(title)
    let buflist = tabpagebuflist(a:tabnr)
    let winnr = tabpagewinnr(a:tabnr)
    let bufnr = buflist[winnr - 1]
    let title = wintabs#renderers#bufname(bufnr)
  endif

  let title = substitute(g:wintabs_ui_vimtab_name_format, "%t", title, "g")
  let title = substitute(title, "%n", a:tabnr, "g")
  if (!a:config.is_active)
    let title = ' '.title.' '
  endif
  return title
endfunction

function! wintabs#renderers#tab_sep(config)
  if a:config.is_active && a:config.is_left
    return g:wintabs_ui_active_vimtab_left
  endif
  if a:config.is_active && a:config.is_right
    return g:wintabs_ui_active_vimtab_right
  endif
  return ''
endfunction

function! wintabs#renderers#left_arrow()
  return ' < '
endfunction

function! wintabs#renderers#right_arrow()
  return ' > '
endfunction

