set nocompatible   " Disable vi compatibilty
set encoding=utf-8 " Use UTF-8
syntax enable      " Turn on syntax highlighting
set showmatch      " Show matching brackets
set ignorecase     " Do case insensitive matching
set number         " Show numbers
set relativenumber " Show relative numbers
set undolevels=999 " Lots of these
set hlsearch       " Highlight Search
set tabstop=4      " Tab size
set shiftwidth=4   " Indentation size
set softtabstop=4  " Tabs/Spaces interop
set expandtab      " Expands tab to spaces
set nomodeline     " Disable as a security precaution
set mouse=a        " Enable mouse mode
set autoindent     " Enable autoindent
set complete-=i    " Better completion
set laststatus=2   " Always show status line
set ruler          " Show cursor position
set scrolloff=3    " Scroll offset
set sidescrolloff=5
set autoread       " Reload files on change
set history=1000   " More history
set list           " Highlight non whitespace characters
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,nbsp:_
set noshowmode     " Hide mode in bottom line given lightline
set colorcolumn=100 " Vertical column
set textwidth=90   " Used when formatting text

" allow .vimrc files to reside in project folders
set exrc
set secure

" set these early to make them available to plugins
let mapleader = ","
let maplocalleader = "\\"

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.vim/swap') == 0
    call mkdir($HOME.'/.vim/swap', 'p')
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" Alternative ctags filename
set tags+=.tags

" Disable folding at startup.
set nofoldenable

if exists('+termguicolors')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    "set termguicolors
endif

if $TERM == "rxvt-unicode-256color"
    set notermguicolors     " Disable true colors (urxvt fix)
endif
