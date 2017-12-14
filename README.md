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

    let g:definitive_definitions['javascript'] = '^\s*\zs\(\(const\|let\|var\|function\|class\)\s\+%1\>\|%1\s*(.*)\s*{\)'
    let g:definitive_definitions['some_other_filetype'] = 'some\+other.*fancy\\regex\s%1'

Note: `%1` is used as the placeholder for the keyword that will be grepped for, so don't forget to include it somewhere in your regex. PS: If you can come up with a regex for a language that vim-definitive does not currently support by default, let me know or create a PR!

Languages currently supported by default:
- Javascript (and Typescript)
- Python
- Ruby
- Vimscript

## Installation

Install it however you usually install plugins.

For example, if you use [Vim-Plug](https://github.com/junegunn/vim-plug), simply add to your vimrc:

    Plug 'misterbuckley/vim-definitive'

[Pathogen](https://github.com/tpope/vim-pathogen) users:

    cd ~/.vim/bundle
    git clone https://github.com/misterbuckley/vim-definitive.git
