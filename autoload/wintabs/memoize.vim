let s:cache = {}

function! wintabs#memoize#call(...)
  let hash = string(a:000)
  if has_key(s:cache, hash)
    return s:cache[hash]
  else
    let value = call(a:1, a:000[1:])
    let s:cache[hash] = value
    return value
  endif
endfunction

function! wintabs#memoize#clear()
  let s:cache = {}
endfunction
