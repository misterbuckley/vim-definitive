# vim-definitive

Jump to the definitions of variables, classes, functions, etc., without relying on tags. To definity and beyond!

## Usage

vim-definitive is definitively simple to use!

### Commands

`:FindDefinition` uses `:grep` to search for the definition of the word under the cursor.

`:FindDefinition FunctionOrVariableName` greps for the definition of FunctionOrVariableName.

All matches are populated into the quickfix list. If a single match is found, FindDefinition will jump to the definition immediately. If more than one match is found, FindDefinition will open the quickfix list and jump to the first match. If there is a match within the current file, FindDefinition will jump to the first match before the cursor, opening the quickfix list if there are any more matches.

### Mappings

No mappings are created by default, so I recommend mapping :FindDefinition to something simple, a la:

    nnoremap <Leader>d :FindDefinition<CR>

### Settings

`g:definitive_definitions` contains the regex dictionary used to search for definitions based on filetype. To append to this dictionary or override an existing definition, simply extend `g:definitive_definitions` as follows:

    let g:definitive_definitions = {
          \ 'javascript': '\<\(\(const\|let\|var\)\s\+%1\>\|\(function\s\+\)\=%1\s*(.*)\s*{\|class\s\+%1\s*{\)',
          \ 'some_other_filetype': 'some\+other.*fancy\\regex\s%1'
          \}

Note: `%1` is used as the placeholder for the keyword that will be grepped for, so don't forget to include it somewhere in your regex. PS: If you can come up with a regex for a language that vim-definitive does not currently support by default, let me know or create a PR!

Languages currently supported by default:
- Javascript (and Typescript)
- Python
- Ruby
- Vimscript

`g:definitive_root_markers` is the list of project root directory markers.
These are files or directories which typically mark the root directory of a
given project. vim-definitive uses this list to determine where it should be
looking when it is searching for definitions. Common examples include .git or
.hg directories or a Makefile, Gemfile, or Pipfile, and so on. You can extend
this list as follows:

    let g:definitive_root_markers = {
          \ 'all': [ '.git', '.gitignore', '.hg', '.hgignore', 'Makefile' ],
          \ 'javascript': [ 'package.json' ]
          \}

Note that this is filetype-specific, and that vim-definitive will search first
for those files listed for the current filetype, and then for any listed under
'all'.

Also note that your extensions will overwrite the defaults for that filetype.
For example, the default for javascript is to look for package.json, so if you
did something like `javascript: [ 'node_modules' ]`, vim-definitive would no
longer look for the package.json file.

`g:definitive_jump_to_first_match` determines when vim-definitive will jump to the first match found

If 2, always jump to the first match found. If 1, only jump to the first match found if there is only a single match. If 0, never jump to the first match found. (default: 1)

Note: Regardless of what this is set to, vim-definitive will always jump to a
match if there is one found within the current file.

`g:definitive_open_quickfix` determines when vim-definitive opens the quickfix list

If 2, always open the quickfix list. If 1, only open the quickfix list if there is more than one match. If 0, never open the quickfix list, even if there is more than one match. (default: 1)

## Installation

Install it however you usually install plugins.

For example, if you use [Vim-Plug](https://github.com/junegunn/vim-plug), simply add to your vimrc:

    Plug 'misterbuckley/vim-definitive'

[Pathogen](https://github.com/tpope/vim-pathogen) users:

    cd ~/.vim/bundle
    git clone https://github.com/misterbuckley/vim-definitive.git

