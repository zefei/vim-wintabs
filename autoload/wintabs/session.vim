" init wintab session, should be run only once
function! wintabs#session#init()
  " init session variable, session globals must start with an uppercase letter
  let s:session = {}
  let g:Wintabs_session_string = '{}'

  " support https://github.com/xolox/vim-session
  if exists('g:session_persist_globals')
    call add(g:session_persist_globals, 'g:Wintabs_session_string')
  else
    let g:session_persist_globals = ['g:Wintabs_session_string']
  endif

  " load wintabs session after Vim loading its session
  autocmd SessionLoadPost * call wintabs#session#load()
endfunction

" save buflist of one window to session
function! wintabs#session#save(tabpage, window, buflist)
  if !has_key(s:session, a:tabpage)
    let s:session[a:tabpage] = {}
  endif

  let s:session[a:tabpage][a:window] = []

  " bufnr isn't persisted across sessions, but bufname is
  for buffer in a:buflist
    call add(s:session[a:tabpage][a:window], bufname(buffer))
  endfor

  let g:Wintabs_session_string = string(s:session)
endfunction

" load session
function! wintabs#session#load()
  execute 'let s:session = '.g:Wintabs_session_string
  for [tabpage, winlist] in items(s:session)
    " continue if tabpage no longer exists
    if tabpage > tabpagenr('$')
      continue
    endif

    for [window, bufnamelist] in items(winlist)
      " continue if window no longer exists
      if window > tabpagewinnr(tabpage, '$')
        continue
      endif

      " map bufnames to bufnrs
      let buflist = []
      for name in bufnamelist
        if bufexists(name)
          call add(buflist, bufnr(name))
        endif
      endfor

      call settabwinvar(tabpage, window, 'wintabs_buflist', buflist)
    endfor
  endfor

  " refresh tabline
  call wintabs#init()
endfunction
