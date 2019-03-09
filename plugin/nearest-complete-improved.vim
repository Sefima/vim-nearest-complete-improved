
" TODO: Ignore comments and keywords?
let s:open_seps = '(\s|\(|\"|\`|\[|\{|\:|\,|\.|\/|;)'
let s:close_seps = '(\s|\)|\"|\`|\]|\}|\:|\,|\.|\/|;)'

" Comparison function used for sorting a list of lists.
" Sorts based on the first value of each sublist
func! s:FirstListItemCompare(i1, i2)
   return a:i1[0] ==# a:i2[0] ? 0 : a:i1[0] > a:i2[0] ? 1 : -1
endfunc


function! s:MatchStrAll(str, pat)
    let l:res = []
    call substitute(a:str, a:pat, '\=add(l:res, submatch(0))', 'g')
    return l:res
endfunction

function! s:GetMatchesFromOtherBuffers(regex)
    let buff_list = filter(range(1, bufnr('$')), 'bufexists(v:val)')
    let curr_buff_i = bufnr('%')
    let words = []
    let i = 0
    let content = ""
    for i in buff_list
        if (i != curr_buff_i)
            let buff_content = getbufline(i, 1, '$')
            let content = content . join(buff_content)
        endif
    endfor
    let results = s:MatchStrAll(content, a:regex)
    return results
endfunction

func! s:generateRegexp(base)
  let needle = a:base
  let open_seps = '(^' . s:open_seps . ')*'
  let close_seps = '(^' . s:close_seps . ')*'
  let expander = '(\a|\d|_|\$|\#)*'
  let full_exp = '\<\c\v' . open_seps . expander . needle . expander . close_seps
  return full_exp
endfunc

" Finds all the words starting with a:base and returns them along with the
" distance in lines from the initial cursor position:
"      [[first_word_line_distance, first_word], [second_word_line_distance, second_word], ...]
" Searches above or below the cursor based on a:go_backwards
func! s:FindWords(base, go_backwards)
  let flags = ''
  if a:go_backwards
    let flags = 'b'
  endif
  let orig_cursor = getpos('.')
  let words = []

  let start = searchpos(s:generateRegexp(a:base), 'W' . flags)
  while start !=# [0, 0]
    let end = searchpos('\>', 'W')
    " If we moved to a new line it's an exact match, which we don't want
    " anyway
    if start[0] ==# end[0]
      let word = getline('.')[start[1]-1:end[1]-2]
      if word !=? a:base
        if a:go_backwards
          let line_dist = orig_cursor[1] - start[0]
        else
          let line_dist = start[0] - orig_cursor[1]
        endif
        call add(words, [line_dist, word])
      endif
    endif
    call cursor(start)
    let start = searchpos(s:generateRegexp(a:base), 'W' . flags)
  endwhile


  call cursor(orig_cursor[1], orig_cursor[2])
  return words
endfunc


" The completefunc for nearest-word completion
func! g:NearestComplete(findstart, base)
  set ignorecase
  set smartcase

  if a:findstart

    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    let seps = ['{', '.', ' ', '#', '(', '}', ')', ',', ':', ';', '"', "'", '`', '\/', '!', '[', ']', '$']

    while start > 0 && index(seps, line[start - 1]) == -1
      let start -= 1
    endwhile
    return start

  else

    " Don't show anything if we're searching for the empty string
    if a:base ==# ''
      return []
    endif

    let words = s:FindWords(a:base, 0) + s:FindWords(a:base, 1)

    " Order the words by distance from the original cursor position
    let sorted = sort(words, "s:FirstListItemCompare")

    " Remove the distance variable and any duplicates
    let res = []
    for i in sorted
      if index(res, i[1]) == -1
        call add(res, i[1])
      endif
    endfor

    let regex = s:generateRegexp(a:base)
    let res = res + s:GetMatchesFromOtherBuffers(regex)
    return res
  endif
endfun


