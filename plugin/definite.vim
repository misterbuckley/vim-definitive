if exists('g:loaded_definite')
  finish
endif
let g:loaded_definite = 1

let g:definite_definitions = {
      \ 'javascript': '^\s*\zs\(\(const\|let\|var\|function\)\s\+%1\>\|%1\s*(.*)\s*{\)',
      \ 'typescript': '^\s*\zs\(\(const\|let\|var\|function\)\s\+%1\>\|%1\s*(.*)\s*{\)',
      \ 'vim': '^\s*\zs\(let\|function[!]\)\s\+\([agls]:\)\=%1\>',
      \ 'ruby': '^\s*\zs\(\(def\|class\)\s\+%1\>\|%1\s*=\)'
      \}

function! definite#FindDefinition()
  if has_key(g:definition_map, &ft)
    let l:function_name = expand("<cword>")
    let l:definition = g:definition_map[&ft]
    let l:search_text = substitute(l:definition, "%1", l:function_name, "g")
    let l:match_in_current_file = search(l:search_text, 'wcb')

    if exists(':Ggrep')
      exec "silent Ggrep! " . l:function_name

    else
      exec "silent grep! " . l:function_name
    endif

    redraw!

    let l:grep_results = getqflist()
    call filter(l:grep_results, 'v:val["text"] =~ l:search_text')
    call setqflist(l:grep_results)

    if l:match_in_current_file
      if len(l:grep_results) > 1
        cope
        wincmd p
      endif

      exec l:match_in_current_file

    elseif len(l:grep_results) == 0
      echo "Definition not found for `" . l:function_name . "`"

    else
      if len(l:grep_results) > 1
        cope
      endif

      cfir
    endif

  else
    echo "Filetype `" . &ft . "` not supported"

  endif
endfunction

command! -nargs=0 FindDefinition :call definite#FindDefinition()
