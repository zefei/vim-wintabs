" init wintab undo list, should be run only once
function! wintabs#undo#init()
  let s:undo = []

  " set session global
  let g:Wintabs_undo_string = '[]'
  if exists('g:session_persist_globals')
    call add(g:session_persist_globals, 'g:Wintabs_undo_string')
  else
    let g:session_persist_globals = ['g:Wintabs_undo_string']
  endif

  autocmd SessionLoadPost * call wintabs#undo#load_from_session()
endfunction

function! wintabs#undo#push(buffer)
  let pathname = bufname(a:buffer)
  if !buflisted(a:buffer) || !filereadable(pathname)
    return
  endif

  " remove previous occurrence
  let idx = index(s:undo, pathname)
  if idx != -1
    call remove(s:undo, idx)
  endif

  call add(s:undo, pathname)

  " apply undo limit
  if len(s:undo) > g:wintabs_undo_limit * 2
    let s:undo = s:undo[:g:wintabs_undo_limit]
  endif

  " serialize to session global
  let g:Wintabs_undo_string = string(s:undo)
endfunction

function! wintabs#undo#peak()
  if len(s:undo) > 0
    return s:undo[-1]
  endif
endfunction

function! wintabs#undo#pop()
  if len(s:undo) == 0
    return
  endif

  let buffer = remove(s:undo, -1)

  " serialize to session global
  let g:Wintabs_undo_string = string(s:undo)

  return buffer
endfunction

function! wintabs#undo#load_from_session()
  execute 'let s:undo = '.g:Wintabs_undo_string
endfunction
