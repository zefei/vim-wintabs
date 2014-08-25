" init wintab session, should be run only once
function! wintabs#session#init()
  " init session variable, it must start with an uppercase letter
  let g:Wintabs_session = {}

  " support https://github.com/xolox/vim-session
  if exists('g:session_persist_globals')
    call add(g:session_persist_globals, 'g:Wintabs_session')
  else
    let g:session_persist_globals = ['g:Wintabs_session']
  endif

  " load wintabs session after Vim loading its session
  autocmd SessionLoadPost * call wintabs#session#load()
endfunction

" save buflist of one window to session
function! wintabs#session#save(tabpage, window, buflist)
  if !has_key(g:Wintabs_session, a:tabpage)
    let g:Wintabs_session[a:tabpage] = {}
  endif

  let g:Wintabs_session[a:tabpage][a:window] = []

  " bufnr isn't persisted across sessions, but bufname is
  for buffer in a:buflist
    call add(g:Wintabs_session[a:tabpage][a:window], bufname(buffer))
  endfor
endfunction

" load session
function! wintabs#session#load()
  for [tabpage, winlist] in items(g:Wintabs_session)
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
