set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"
" " alternatively, pass a path where Vundle should install plugins
" "call vundle#begin('~/some/path/here')
"
" " let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
"
" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)

Plugin 'Valloric/YouCompleteMe'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'jiangmiao/auto-pairs'
Plugin 'luochen1990/rainbow'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'flazz/vim-colorschemes'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'scrooloose/nerdtree'
Plugin 'Yggdroot/indentLine'
Plugin 'itchyny/vim-haskell-indent'
Plugin 'vim-pandoc/vim-pandoc'
Plugin 'vim-pandoc/vim-pandoc-syntax'
Plugin 'tpope/vim-fugitive'

" Plugin 'scrooloose/syntastic' " Plugin 'venantius/vim-eastwood'



" " All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

let g:cpp_member_variable_highlight = 1
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_python_binary_path = '/usr/bin/python'
let g:ycm_auto_trigger = 1
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'

let g:airline#extensions#tabline#enabled = 1

" don't conceal in MD
let g:pandoc#syntax#conceal#use = 0


" Enable gcc syntax checker and get rid of ycm syntax
" let g:syntastic_cpp_checkers = ['gcc']
" let g:ycm_show_diagnostics_ui = 0


let g:rainbow_active = 0

map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>


set backspace=2 " make backspace work like most other apps

syntax enable
set background=dark
colorscheme jellybeans

" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set softtabstop=4
set expandtab
set smarttab
set autoindent
set copyindent
set number
set cursorline
set hlsearch
set autowrite
set statusline +=\ %{fugitive#statusline()}
set clipboard=unnamed 
" use system clipboard


autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
autocmd FileType clj call rainbow#load()
autocmd BufNewFile,BufRead *.s   set syntax=mips
autocmd BufNewFile,BufRead *.s   set noexpandtab shiftwidth=8 softtabstop=0
au BufNewFile,BufRead *.ejs set filetype=html
au BufNewFile,BufRead *.cql set filetype=sql


map <F7> mzgg=G`z
" for moveing around window pains
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

