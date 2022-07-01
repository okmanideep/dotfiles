syntax on
set fileformats=unix,dos
set hidden "Moving out of the file hides it and doesn't close
set noerrorbells

set number
set relativenumber
set tabstop=2
set expandtab
set shiftwidth=4
set smartindent
set nowrap
set smartcase
set colorcolumn=80

set scrolloff=3

set signcolumn=yes

"dont highlight search results
set nohlsearch

"highlight search results as you type
set incsearch

"Display whitespace characters
set encoding=utf-8
set magic
set listchars=tab:│\ ,trail:·
set list

set title
set titlestring=%{expand(\"%:p:\~:h\")}

" Auto write file when FocusLost
" no swaps or backups
set autowriteall
augroup autosave
    au!
    au FocusLost,BufLeave * :wa
augroup END
set noswapfile
set nobackup
set nowritebackup
set undodir=~/.vim/undodir
set undofile

set wildignore+=*.class,*.pyc,*.iml

"nvim terminal esc
:tnoremap <Esc> <C-\><C-n>

if executable('rg')
    let g:rg_derive_root='true'
endif

"Faster movements
nnoremap T <C-u>
nnoremap B <C-d>
vnoremap T <C-u>
vnoremap B <C-d>

"Switch splits faster
:nnoremap <C-h> <C-w>h
:nnoremap <C-j> <C-w>j
:nnoremap <C-k> <C-w>k
:nnoremap <C-l> <C-w>l
:tnoremap <C-h> <C-\><C-n><C-w>h
:tnoremap <C-j> <C-\><C-n><C-w>j
:tnoremap <C-k> <C-\><C-n><C-w>k
:tnoremap <C-l> <C-\><C-n><C-w>l

"go to cmd mode more easily
nnoremap ; :
vnoremap ; :

"alternative for `;` since `;` is mapped to `:`
"this line needs to be after changing the leader from \
nnoremap \ ;

" Open netrw on the left using '-'
nnoremap <silent> - :Ex<CR>
let g:netrw_banner=0
let g:netrw_winsize=25
let g:netrw_sort_by="time"
let g:netrw_sort_direction="reverse"

"change leader from \ to space
let mapleader = " "

"quickly edit/reload the vimrc file
nnoremap <silent> <leader>ev :e $MYVIMRC<CR>
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>

" Copy to clipboard and paste from clipboard
:vnoremap <leader>y "+y
:vnoremap <leader>p "+p
:nnoremap <leader>y "+y
:nnoremap <leader>p "+p

nnoremap <silent> <leader>rl :w<CR>:e!<CR>

" Open terminal on the left
nnoremap <leader>t :sp <CR>:term<CR>:resize 10<CR>A

call plug#begin('~/.vim/plugged')

"lspconfig
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
"lsp completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'p00f/nvim-ts-rainbow'

"telescope - fuzzy finder
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kyazdani42/nvim-web-devicons'
nnoremap <leader>o <cmd>Telescope find_files<cr>
nnoremap <leader>h <cmd>Telescope help_tags<cr>
nnoremap <leader>f <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <leader>F <cmd>Telescope live_grep<cr>

"color schemes"
Plug 'joshdick/onedark.vim'

" lightline status bar
Plug 'itchyny/lightline.vim'
let g:lightline={'colorscheme':'onedark'}

"toggle comments"
Plug 'preservim/nerdcommenter'

" Vertically align multiple lines
Plug 'godlygeek/tabular'
nnoremap ga :Tabularize /
vnoremap ga :Tabularize /
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
" Automatically align table when '|' is typed
function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

"Auto closing brackets and quotes"
Plug 'Raimondi/delimitMate'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

Plug 'tpope/vim-fugitive'

Plug 'editorconfig/editorconfig-vim'

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install'  }
Plug 'preservim/vim-markdown'
let g:vim_markdown_conceal_code_blocks = 0
nmap gm <Plug>MarkdownPreview
nmap <CR> <Plug>Markdown_OpenUrlUnderCursor

Plug 'gerw/vim-HiLinkTrace'
call plug#end()

set completeopt=menu,menuone,noselect

colorscheme onedark
let g:onedark_terminal_italics = 1
set background=dark
set termguicolors
set noshowmode

set nofoldenable

function s:OpenNote()
    let l:url = 'http://localhost:3000/'.expand('%:t:r')
    call netrw#BrowseX(l:url,netrw#CheckIfRemote())
endfunction

command! ViewNoteInBrowser :call <SID>OpenNote()
nnoremap gn <cmd>ViewNoteInBrowser<CR>

lua require("okmanideep")
