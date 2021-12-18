syntax on
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
if(has("nvim"))
    :tnoremap <Esc> <C-\><C-n>
endif

if executable('rg')
    let g:rg_derive_root='true'
endif

"Faster movements
nnoremap J 5j
nnoremap K 5k
vnoremap J 5j
vnoremap K 5k
nnoremap T <C-u>
nnoremap B <C-d>

"Switch splits faster - replaced by Plug 'christoomey/vim-tmux-navigator'
":nnoremap <C-h> <C-w>h
":nnoremap <C-j> <C-w>j
":nnoremap <C-k> <C-w>k
":nnoremap <C-l> <C-w>l
"if(has("nvim")) 
"    :tnoremap <C-h> <C-\><C-n><C-w>h
"    :tnoremap <C-j> <C-\><C-n><C-w>j
"    :tnoremap <C-k> <C-\><C-n><C-w>k
"    :tnoremap <C-l> <C-\><C-n><C-w>l
"endif

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

"Autocomplete"
Plug 'neoclide/coc.nvim', {'branch': 'release'}
set updatetime=300
set shortmess+=c
set signcolumn=yes
"Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" GoTo code navigation.
nmap gd <Plug>(coc-definition)
nmap gf <Plug>(coc-references)
nmap gr <Plug>(coc-rename)
nnoremap gs :CocSearch <C-R>=expand("<cword>")<CR><CR>
nmap g[ <Plug>(coc-diagnostic-prev)
nmap g] <Plug>(coc-diagnostic-next)
nmap <leader>qf <Plug>(coc-fix-current)
nmap <silent> gp <Plug>(coc-diagnostic-prev-error)
nmap <silent> gn <Plug>(coc-diagnostic-next-error)
nnoremap <leader>cr :CocRestart
" ':Prettier' command to format a json
command! -nargs=0 Prettier :CocCommand prettier.formatFile


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
Plug 'gruvbox-community/gruvbox'
Plug 'altercation/vim-colors-solarized'
Plug 'hzchirs/vim-material'
Plug 'ayu-theme/ayu-vim'
Plug 'rakr/vim-one'
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

Plug 'sheerun/vim-polyglot'
let g:vim_markdown_conceal_code_blocks = 0
nmap <CR> <Plug>Markdown_OpenUrlUnderCursor

Plug 'editorconfig/editorconfig-vim'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_code_completion_enabled = 0
let g:go_imports_autosave = 1
let g:go_def_mapping_enabled = 0
let g:go_doc_keywordprg_enabled = 0


Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install'  }
nmap gm <Plug>MarkdownPreview

Plug 'gerw/vim-HiLinkTrace'

Plug 'christoomey/vim-tmux-navigator'

Plug '/home/manideep/Documents/code/personal/vim-settings'
call plug#end()

colorscheme onedark
let g:onedark_terminal_italics = 1
set background=dark
set termguicolors
set noshowmode

highlight   String         cterm=italic   gui=italic
highlight   Boolean        cterm=italic   gui=italic
highlight   Type           cterm=italic   gui=italic
highlight   StorageClass   cterm=italic   gui=italic
highlight   Structure      cterm=italic   gui=italic
highlight   Conditional    cterm=italic   gui=italic
highlight   Repeat         cterm=italic   gui=italic
highlight   Label          cterm=italic   gui=italic
highlight   Keyword        cterm=italic   gui=italic
highlight   Exception      cterm=italic   gui=italic
highlight   Include        cterm=italic   gui=italic

function s:OpenNote()
    let l:url = 'http://localhost:3000/'.expand('%:t:r')
    call netrw#BrowseX(l:url,netrw#CheckIfRemote())
endfunction

command! ViewNoteInBrowser :call <SID>OpenNote()
nnoremap gn <cmd>ViewNoteInBrowser<CR>

lua require("okmanideep")
