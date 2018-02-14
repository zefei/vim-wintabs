function! wintabs#renderers#defaults()
  return {
        \'buffer': function('wintabs#renderers#buffer'),
        \'buffer_sep': function('wintabs#renderers#buffer_sep'),
        \'tab': function('wintabs#renderers#tab'),
        \'tab_sep': function('wintabs#renderers#tab_sep'),
        \'left_arrow': function('wintabs#renderers#left_arrow'),
        \'right_arrow': function('wintabs#renderers#right_arrow'),
        \'line_sep': function('wintabs#renderers#line_sep'),
        \}
endfunction

function! wintabs#renderers#buffer(bufnr, config)
  return {
        \'label': wintabs#renderers#buf_label(a:bufnr),
        \'highlight': a:config.is_active ? g:wintabs_ui_active_higroup : '',
        \}
endfunction

function! wintabs#renderers#buffer_sep(config)
  let label = g:wintabs_ui_sep_inbetween
  if a:config.is_leftmost
    let label = g:wintabs_ui_sep_leftmost
  endif
  if a:config.is_rightmost
    let label = g:wintabs_ui_sep_rightmost
  endif
  if a:config.is_active && a:config.is_left
    let label = g:wintabs_ui_active_left
  endif
  if a:config.is_active && a:config.is_right
    let label = g:wintabs_ui_active_right
  endif
  return {
        \'label': label,
        \'highlight': a:config.is_active ? g:wintabs_ui_active_higroup : '',
        \}
endfunction

function! wintabs#renderers#tab(tabnr, config)
  let label = wintabs#renderers#tab_label(a:tabnr)
  if (!a:config.is_active)
    let label = ' '.label.' '
  endif
  return {
        \'label': label,
        \'highlight': a:config.is_active ? g:wintabs_ui_active_higroup : '',
        \}
endfunction

function! wintabs#renderers#tab_sep(config)
  let label = ''
  if a:config.is_active && a:config.is_left
    let label = g:wintabs_ui_active_vimtab_left
  endif
  if a:config.is_active && a:config.is_right
    let label = g:wintabs_ui_active_vimtab_right
  endif
  return {
        \'label': label,
        \'highlight': a:config.is_active ? g:wintabs_ui_active_higroup : '',
        \}
endfunction

function! wintabs#renderers#left_arrow()
  return {
        \'type': 'left_arrow',
        \'label': g:wintabs_ui_arrow_left,
        \'highlight': '',
        \}
endfunction

function! wintabs#renderers#right_arrow()
  return {
        \'type': 'right_arrow',
        \'label': g:wintabs_ui_arrow_right,
        \'highlight': '',
        \}
endfunction

function! wintabs#renderers#line_sep()
  return {
        \'type': 'sep',
        \'label': g:wintabs_ui_sep_spaceline,
        \'highlight': '',
        \}
endfunction

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

function! wintabs#renderers#buf_label(bufnr)
  let label = wintabs#renderers#bufname(a:bufnr)
  let label = substitute(g:wintabs_ui_buffer_name_format, "%t", label, "g")
  let label = substitute(label, "%n", a:bufnr, "g")
  return label
endfunction

function! wintabs#renderers#tab_label(tabnr)
  let label = ''
  if get(g:, 'loaded_taboo', 0)
    let label = TabooTabTitle(a:tabnr)
  endif

  if empty(label) && exists('*gettabvar')
    let label = gettabvar(a:tabnr, 'label')
  endif

  if empty(label)
    let buflist = tabpagebuflist(a:tabnr)
    let winnr = tabpagewinnr(a:tabnr)
    let bufnr = buflist[winnr - 1]
    let label = wintabs#renderers#bufname(bufnr)
  endif

  let label = substitute(g:wintabs_ui_vimtab_name_format, "%t", label, "g")
  let label = substitute(label, "%n", a:tabnr, "g")
  return label
endfunction
