if exists('g:loaded_definitive')
  finish
endif
let g:loaded_definitive = 1

let s:definitive_definitions = {
      \ 'elixir': '\<\(def\(p\|module\|impl\|protocol\|macro\)\=\s\+%1\>\|%1\s*=\)',
      \ 'javascript': '\<\(\(const\|let\|var\)\s\+%1\>\|\(function\s\+\)\=%1\s*(.*)\s*{\|class\s\+%1\s*{\)',
      \ 'javascript.jsx': '\<\(\(const\|let\|var\)\s\+%1\>\|\(function\s\+\)\=%1\s*(.*)\s*{\|class\s\+%1\s*{\)',
      \ 'kotlin': '\<\(val\|var\|fun\|class\|trait\|object\)\s\+%1\>',
      \ 'lua': '\(\(\<\([^=]\+,\s*\)\?\|\.\)%1\(\s*,[^=]\+\)\?\s*=\|\<function\s\+\(\w\+\.\)\?%1\>\)',
      \ 'php': '\s*\(\zs\$%1\>\s*=\|\(function\s\+\)%1\s*(.*)\s*{\|class\s\+%1\s*{\|define\s*(\s*[''"]%1\)',
      \ 'python': '\<\(\(def\|class\)\s\+%1\>\|%1\s*=\)',
      \ 'ruby': '\<\(\(def\|class\|module\|alias\)\s\+\(self\.\)\=%1\>\|%1\s*=\|\<\(alias_method\|attr_reader\|attr_accessor\|delegate\|attribute\|serialize\|scope\|has_one\|has_many\|has_and_belongs_to_many\|belongs_to\|has_one_attached\) :%1\>\)',
      \ 'scala': '\<\(val\|var\|def\|class\|trait\|object\)\s\+%1\>',
      \ 'sh': '\<\(function\s\+%1\|%1()\|%1=\)',
      \ 'typescript': '\<\(\(const\|let\|var\|type\|interface\)\s\+%1\>\|\(function\s\+\)\=%1\s*(.*)\s*{\|class\s\+%1\s*{\)',
      \ 'c': '\<\(\(struct\|enum\)\s\+%1\s*{\|\w\+\s\+%1\s*(.*)\s*{\|\w\+\s\+%1\s*[;=]\)',
      \ 'cpp': '\<\(\(class\|struct\|enum\|namespace\)\s\+%1\>\|\w\+\s\+%1\s*(.*)\s*{\|\w\+\s\+%1\s*[;=]\)',
      \ 'cs': '\<\(\(class\|interface\|enum\|struct\)\s\+%1\>\|\w\+\s\+%1\s*(.*)\s*{\|\w\+\s\+%1\s*[;=]\)',
      \ 'go': '\<\(func\|type\|var\|const\)\s\+%1\>\|\<%1\s*:=',
      \ 'java': '\<\(class\|interface\|enum\)\s\+%1\>\|\w\+\s\+%1\s*(.*)\s*{\|\w\+\s\+%1\s*[;=]',
      \ 'perl': '\<\(sub\s\+%1\>\|\(my\|our\)\s\+\$%1\)',
      \ 'r': '\<%1\s*<-\|\<%1\s*=\|\<%1\s*<-\s*function',
      \ 'rust': '\<\(fn\|struct\|enum\|trait\|type\|mod\)\s\+%1\>\|\<let\s\+\(mut\s\+\)?%1\s*[:=]',
      \ 'swift': '\<\(func\|class\|struct\|enum\|protocol\|typealias\|let\|var\)\s\+%1\>',
      \ 'haskell': '\<\(data\|newtype\|type\|class\)\s\+%1\>\|\<%1\s*::\|\<%1\s*=',
      \ 'css': '\([.#]\)%1[^,{]*{',
      \ 'scss': '\$%1\s*:\|@\(mixin\|function\)\s\+%1\>\|%\s*%1\s*{',
      \ 'vim': '\<\(let\s\+\([agls]:\)\?%1\s*=\|function!\?\s\+\([agls]:\)\?%1\s*(\)'
      \}
let s:definitive_root_markers = {
      \ 'all': [ '.git', '.gitignore', '.hg', '.hgignore', 'Makefile' ],
      \ 'javascript': [ 'package.json' ],
      \ 'javascript.jsx': [ 'package.json' ],
      \ 'python': [ 'Pipfile' ],
      \ 'ruby': [ 'Gemfile' ],
      \ 'scala': [ 'build.sbt' ],
      \ 'typescript': [ 'package.json' ],
      \ 'c': [ 'Makefile' ],
      \ 'cpp': [ 'CMakeLists.txt' ],
      \ 'cs': [ 'project.json' ],
      \ 'go': [ 'go.mod' ],
      \ 'java': [ 'pom.xml' ],
      \ 'perl': [ 'Makefile.PL' ],
      \ 'rust': [ 'Cargo.toml' ],
      \ 'swift': [ 'Package.swift' ],
      \ 'haskell': [ 'stack.yaml' ],
      \ 'r': [ 'DESCRIPTION' ]
      \}

let s:definitive_jump_to_first_match = 1
let s:definitive_open_quickfix = 1

function! definitive#FindDefinition(...)
  call s:GetSettings()

  if has_key(g:definitive_definitions, &ft)
    let l:definition = g:definitive_definitions[&ft]

  elseif has_key(g:definitive_associated_filetypes, &ft)
    let l:definition = g:definitive_definitions[g:definitive_associated_filetypes[&ft]]

  else
    echo "Filetype `" . &ft . "` not supported"
    return
  end

  if a:0 > 0
    let l:wanted_definition = a:1

  else
    let l:wanted_definition = expand("<cword>")
  endif

  let l:search_text = substitute(l:definition, "%1", l:wanted_definition, "g")
  let l:match_in_current_file = search(l:search_text, 'wcbs')

  let l:grepprg_save = &grepprg
  let l:grepformat_save = &grepformat
  let l:pwd_save = getcwd()
  exec 'cd ' . s:GetProjectRoot()

  if s:IsInGitRepo()
    set grepprg=git\ grep\ -n\ --no-color\ --untracked\ --column
    set grepformat=%f:%l:%c:%m
  endif

  exec "silent grep! " . escape(l:wanted_definition, '#')

  let &grepprg = l:grepprg_save
  let &grepformat = l:grepformat_save
  exec 'cd ' . l:pwd_save

  redraw!

  let l:grep_results = getqflist()
  call filter(l:grep_results, 'v:val["text"] =~ l:search_text')
  call setqflist(l:grep_results)

  if len(l:grep_results)
    if g:definitive_open_quickfix == 2
      copen

    elseif g:definitive_open_quickfix == 1
      if len(l:grep_results) > 1
        copen
      endif
    endif

    if l:match_in_current_file
      call searchpos(l:wanted_definition, 'c', l:match_in_current_file)

    elseif g:definitive_jump_to_first_match == 2
      cfirst

    elseif g:definitive_jump_to_first_match == 1
      if len(l:grep_results) == 1
        cfirst
      endif
    endif

  else
    cclose

    if !l:match_in_current_file
      echo "Definition not found for `" . l:wanted_definition . "`"
    endif
  endif
endfunction

function! s:GetSettings()
  if exists('g:definitive_definitions')
    let g:definitive_definitions = extend(s:definitive_definitions, g:definitive_definitions)

  else
    let g:definitive_definitions = s:definitive_definitions
  endif

  for l:lang in items(g:definitive_definitions)
    if type(l:lang[1]) == 4 && has_key(l:lang[1], 'extends')
      let g:definitive_definitions[l:lang[0]] = g:definitive_definitions[l:lang[1]['extends']]
    endif
  endfor

  if exists('g:definitive_root_markers')
    let g:definitive_root_markers = extend(s:definitive_root_markers, g:definitive_root_markers)

  else
    let g:definitive_root_markers = s:definitive_root_markers
  endif

  if !exists('g:definitive_jump_to_first_match')
    let g:definitive_jump_to_first_match = s:definitive_jump_to_first_match
  endif

  if !exists('g:definitive_open_quickfix')
    let g:definitive_open_quickfix = s:definitive_open_quickfix
  endif
endfunction

function! s:IsInGitRepo()
  return executable('git') && system('git rev-parse --is-inside-work-tree') =~ 'true'
endfunction

function! s:GetProjectRoot()
  if s:IsInGitRepo()
    return system('git rev-parse --show-toplevel')
  endif

  if has_key(g:definitive_root_markers, &ft)
    let l:root_markers = extend(g:definitive_root_markers[&ft], g:definitive_root_markers['all'])

  elseif has_key(g:definitive_associated_filetypes, &ft)
    let l:root_markers = extend(g:definitive_root_markers[g:definitive_associated_filetypes[&ft]], g:definitive_root_markers['all'])

  else
    let l:root_markers = g:definitive_root_markers['all']
  endif

  let l:found_root = 0

  let l:current_dir = expand('%:p')

  while !l:found_root && l:current_dir != '/'
    let l:current_dir = '/' . join(split(l:current_dir, '/')[:-2], '/')

    for l:filename in l:root_markers
      if filereadable(l:current_dir . '/' . l:filename) || isdirectory(l:current_dir . '/' . l:filename)
        let l:found_root = 1
        break
      endif
    endfor
  endwhile

  if l:found_root
    return l:current_dir

  else
    return expand('%:p:h')
  endif
endfunction

command! -nargs=? FindDefinition :call definitive#FindDefinition(<f-args>)
command! -nargs=? SFindDefinition :split | call definitive#FindDefinition(<f-args>)
command! -nargs=? VFindDefinition :vsplit | call definitive#FindDefinition(<f-args>)
