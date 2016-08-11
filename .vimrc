" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

"colorscheme solarized         " awesome colorscheme

" Uncomment the following to have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif


syntax on
set number
set noexpandtab
set shiftwidth=4
set tabstop=4
set background=dark
set smartindent
set smartcase
set wrap
set showcmd
set ruler
set incsearch           
set showmatch
set title
set history=2000
set mouse=a
set foldenable  

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

