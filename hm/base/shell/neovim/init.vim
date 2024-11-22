set undodir=$XDG_CACHE_HOME/nvim/undo
set directory=$XDG_CACHE_HOME/nvim/swap
set backupdir=$XDG_CACHE_HOME/nvim/backup
set viewdir=$XDG_CACHE_HOME/nvim/view

" Airline Settings
" Tabbar (top of vim) is enabled
let g:airline#extensions#tabline#enabled = 1
" Use Powerline Fonts (better looking)
let g:airline_powerline_fonts = 1

"" General
" Other
" set wildmenu                    " Opens a menue when there is more than one file/command/...
" set wildmode=longest:full,full  " Shows all possible files/commands/... in a list
set t_Co=256                    " Colors to 256, for TODO
colorscheme nord        " 'silent' to not fail before install
set clipboard=unnamedplus       " use STRG+C/STRG+V - copy-paste-buffer

" Display
set laststatus=2     " Always show status line
set title            " Always show title of document
set number           " Show line numbers
set relativenumber   " Show relative line numbers -> must have set number
set colorcolumn=81   " Shows a colored vertical line at position 81
"set linebreak        " Break lines at word (requires Wrap lines)
"set showbreak=+++    " Wrap-broken line prefix
"set textwidth=100    " Line wrap (number of cols)
set showmatch        " Highlight matching brace
set errorbells       " Beep or flash screen on errors
set visualbell       " Use visual bell (no beeping)
"set nowrap          " TODO vergleiche mit textwrap
"set list             " Replace characters with others TODO really?
"set listchars=tab:>- " Show tabs as >-
syntax on            " Show syntax
set cursorline       " Highlights current cursor line

" Find and Replace
set hlsearch                    " Highlight all search results
set smartcase                   " Enable smart-case search
set ignorecase                  " Always case-insensitive
set incsearch                   " Searches for strings incrementally
set wildignorecase              " case insensitive searching -> TAB completion
"set fileignorecase             " case insensitive file searching -> even without TAB completion
set inccommand=split

" Indentation
set autoindent      " Auto-indent new lines
set expandtab       " Use spaces instead of tabs
set shiftwidth=2    " Number of auto-indent spaces
set smartindent     " Enable smart-indent
set smarttab        " Enable smart-tabs
set softtabstop=2   " Number of spaces per Tab

"" Advanced
" Window
set confirm         " Prompt confirmation dialogs -> saving before exit
set ruler           " Show row and column ruler information
set showtabline=2   " Show tab bar

" Files and Paths
set autochdir                   " Change working directory to open buffer
set path+=**                    " Find recursive files
set backup                      " Activate Backup of old files

" Miscellaneous
set undolevels=1000 " Number of undo levels
set backspace=indent,eol,start  " Backspace behaviour
set whichwrap+=<,>,h,l

" fzf-config
" preview '(highlight -O ansi -l {} 2> /dev/null || cat {}
command! -bang -nargs=? -complete=dir Files
\ call fzf#vim#files(<q-args>, {'options': ['--layout=reverse', '--info=inline', '--preview', 'highlight -O ansi -l {} 2> /dev/null || cat {}']}, <bang>0)

set termguicolors