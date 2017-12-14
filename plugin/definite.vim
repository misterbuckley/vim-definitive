if exists('g:loaded_definite')
  finish
endif
let g:loaded_definite = 1

let g:definite_definitions = {
      \ 'javascript': '^\s*\zs\(\(const\|let\|var\|function\|class\)\s\+%1\>\|%1\s*(.*)\s*{\)',
      \ 'python': '^\s*\zs\(\(def\|class\)\s\+%1\>\|%1\s*=\)',
      \ 'ruby': '^\s*\zs\(\(def\|class\)\s\+%1\>\|%1\s*=\)',
      \ 'typescript': '^\s*\zs\(\(const\|let\|var\|function\|class\)\s\+%1\>\|%1\s*(.*)\s*{\)',
      \ 'vim': '^\s*\zs\(let\|function[!]\)\s\+\([agls]:\)\=%1\>'
      \}

function! definite#FindDefinition(...)
  if has_key(g:definite_definitions, &ft)
    if a:0 > 0
      let l:wanted_definition = a:1

    else
      let l:wanted_definition = expand("<cword>")
    endif

    let l:definition = g:definite_definitions[&ft]
    let l:search_text = substitute(l:definition, "%1", l:wanted_definition, "g")
    let l:match_in_current_file = search(l:search_text, 'wcb')

    let l:grepprg_save = &grepprg
    let l:grepformat_save = &grepformat

    if executable('git')
      set grepprg=git\ grep\ -n\ --no-color
      set grepformat=%f:%l:%m
    endif

    exec "silent grep! " . l:wanted_definition

    let &grepprg = l:grepprg_save
    let &grepformat = l:grepformat_save

    redraw!

    let l:grep_results = getqflist()
    call filter(l:grep_results, 'v:val["text"] =~ l:search_text')
    call setqflist(l:grep_results)

    if l:match_in_current_file
      if len(l:grep_results) > 1
        copen
        wincmd p

      else
        cclose
      endif

      exec l:match_in_current_file

    elseif len(l:grep_results) == 0
      echo "Definition not found for `" . l:wanted_definition . "`"

    else
      if len(l:grep_results) > 1
        copen

      else
        cclose
      endif

      cfir
    endif

  else
    echo "Filetype `" . &ft . "` not supported"

  endif
endfunction

command! -nargs=? FindDefinition :call definite#FindDefinition(<f-args>)
