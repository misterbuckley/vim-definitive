if exists('g:loaded_definitive')
  finish
endif
let g:loaded_definitive = 1

let g:definitive_definitions = {
      \ 'javascript': '^\s*\zs\(\(const\|let\|var\|function\|class\)\s\+%1\>\|%1\s*(.*)\s*{\)',
      \ 'python': '^\s*\zs\(\(def\|class\)\s\+%1\>\|%1\s*=\)',
      \ 'ruby': '^\s*\zs\(\(def\|class\)\s\+%1\>\|%1\s*=\)',
      \ 'typescript': '^\s*\zs\(\(const\|let\|var\|function\|class\)\s\+%1\>\|%1\s*(.*)\s*{\)',
      \ 'vim': '^\s*\zs\(let\|function[!]\)\s\+\([agls]:\)\=%1\>'
      \}

function! definitive#FindDefinition(...)
  if has_key(g:definitive_definitions, &ft)
    if a:0 > 0
      let l:wanted_definition = a:1

    else
      let l:wanted_definition = expand("<cword>")
    endif

    let l:definition = g:definitive_definitions[&ft]
    let l:search_text = substitute(l:definition, "%1", l:wanted_definition, "g")
    let l:match_in_current_file = search(l:search_text, 'wcb')

    let l:grepprg_save = &grepprg
    let l:grepformat_save = &grepformat
    let l:pwd_save = getcwd()
    exec 'cd ' . expand('%:h')

    if s:IsInGitRepo()
      let l:git_repo_root_dir = system('git rev-parse --show-toplevel')
      exec 'cd ' . l:git_repo_root_dir

      set grepprg=git\ grep\ -n\ --no-color
      set grepformat=%f:%l:%m
    endif

    exec "silent grep! " . l:wanted_definition

    let &grepprg = l:grepprg_save
    let &grepformat = l:grepformat_save
    exec 'cd ' . l:pwd_save

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
      cclose
      echo "Definition not found for `" . l:wanted_definition . "`"

    else
      if len(l:grep_results) > 1
        copen

      else
        cclose
      endif

      cfirst
    endif

  else
    echo "Filetype `" . &ft . "` not supported"

  endif
endfunction

function! s:IsInGitRepo()
  return executable('git') && system('git rev-parse --is-inside-work-tree') =~ 'true'
endfunction

command! -nargs=? FindDefinition :call definitive#FindDefinition(<f-args>)
