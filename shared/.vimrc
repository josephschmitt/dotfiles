" =============================================================================
" .vimrc — plain Vim port of the Kickstart Neovim setup
"
" For SSH boxes where Neovim isn't available. Mirrors the option set, key
" bindings, and color palette of shared/.config/nvim/ as closely as Vim 8+
" allows.
"
" Neovim ignores this file (it reads ~/.config/nvim/init.lua), so this is
" only loaded by plain `vim`.
"
" First run: vim-plug auto-installs and runs :PlugInstall on startup.
" =============================================================================

" --- Pre-plugin setup --------------------------------------------------------
set nocompatible
let mapleader = ' '
let maplocalleader = ','

" --- vim-plug bootstrap ------------------------------------------------------
let s:plug_path = expand('~/.vim/autoload/plug.vim')
if !filereadable(s:plug_path)
  silent execute '!curl -fLo ' . s:plug_path . ' --create-dirs '
        \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" --- Plugins -----------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" Editing — direct analogues to mini.surround, mini.comment, mini.repeat
Plug 'tpope/vim-commentary'         " gcc / gc{motion} comment toggle
Plug 'tpope/vim-surround'           " ys / cs / ds surround operators
Plug 'tpope/vim-repeat'             " makes . repeat plugin maps

" Git — closest plain-Vim equivalent to gitsigns + lazygit
Plug 'tpope/vim-fugitive'           " :Git, :Gdiffsplit, :Gblame, etc.

" Fuzzy finder — replacement for snacks.picker / telescope
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'             " :Files, :Buffers, :Rg, :BLines, :Maps

call plug#end()

" =============================================================================
" Options (kickstart init.lua + custom/options.lua parity)
" =============================================================================
set number relativenumber           " absolute + relative line numbers
set mouse=a                         " mouse enabled in all modes
set noshowmode                      " mode is shown elsewhere; suppress -- INSERT --
set clipboard^=unnamedplus          " sync OS clipboard when +clipboard is built
set breakindent                     " wrapped lines preserve indent
set ignorecase smartcase            " case-insensitive unless capitalized
set incsearch hlsearch              " incremental + highlighted search
set signcolumn=yes                  " always-on gutter (matches kickstart)
set updatetime=250                  " faster CursorHold, swap writes
set timeoutlen=300                  " shorter mapping timeout (which-key feel)
set splitright splitbelow           " new splits go right / down
set list listchars=tab:»\ ,trail:·,nbsp:␣  " visible whitespace
set cursorline                      " highlight the current line
set scrolloff=10                    " keep 10 lines of context above/below cursor
set confirm                         " prompt instead of failing on :q with changes
set nowrap                          " no soft-wrap (toggle with <Leader>tw)
set colorcolumn=100                 " vertical ruler
set showmatch                       " brief jump to matching bracket
set lazyredraw                      " smoother macros
set ttyfast                         " faster redraw on local + ssh terms
set hidden                          " allow buffer switch without saving
set backspace=indent,eol,start      " sane backspace
set encoding=utf-8
set fileencoding=utf-8
set ttimeoutlen=10                  " near-instant <Esc> in terminals
set wildmenu wildmode=longest:full,full
set fillchars+=vert:│,horiz:─,horizup:┴,horizdown:┬
set shortmess+=I                    " no intro screen
set history=1000

" Global statusline (Vim 8.2+); falls back gracefully on older Vim
silent! set laststatus=3
if &laststatus !=# 3 | set laststatus=2 | endif

" Persistent undo — survive across sessions
if has('persistent_undo')
  let s:undodir = expand('~/.vim/undo')
  if !isdirectory(s:undodir) | call mkdir(s:undodir, 'p', 0700) | endif
  let &undodir = s:undodir
  set undofile
endif

" Syntax + filetype
syntax enable
filetype plugin indent on

" Sensible defaults for indenting
set expandtab tabstop=2 softtabstop=2 shiftwidth=2 smartindent autoindent

" =============================================================================
" Tokyonight-Moon palette (manual)
" Approximates folke/tokyonight.nvim 'moon' style; needs a true-color terminal.
" =============================================================================
if has('termguicolors')
  " Required for true-color inside tmux/screen
  if &term =~? 'xterm\|screen\|tmux'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
  set termguicolors
endif

set background=dark

function! s:TokyonightMoon() abort
  highlight clear
  if exists('syntax_on') | syntax reset | endif
  let g:colors_name = 'tokyonight-moon'

  " Palette
  let l:bg          = '#222436'
  let l:bg_dark     = '#1e2030'
  let l:bg_hl       = '#2f334d'
  let l:bg_visual   = '#2d3f76'
  let l:fg          = '#c8d3f5'
  let l:fg_dark     = '#828bb8'
  let l:gutter      = '#3b4261'
  let l:comment     = '#7a88cf'
  let l:blue        = '#82aaff'
  let l:blue0       = '#3e68d7'
  let l:cyan        = '#86e1fc'
  let l:magenta     = '#c099ff'
  let l:purple      = '#fca7ea'
  let l:orange      = '#ff966c'
  let l:yellow      = '#ffc777'
  let l:green       = '#c3e88d'
  let l:teal        = '#4fd6be'
  let l:red         = '#ff757f'
  let l:red1        = '#c53b53'

  " Editor
  execute 'highlight Normal       guifg=' . l:fg      . ' guibg=' . l:bg
  execute 'highlight NormalNC     guifg=' . l:fg      . ' guibg=' . l:bg
  execute 'highlight EndOfBuffer  guifg=' . l:bg      . ' guibg=' . l:bg
  execute 'highlight LineNr       guifg=' . l:gutter  . ' guibg=NONE'
  execute 'highlight CursorLineNr guifg=' . l:orange  . ' guibg=NONE gui=bold'
  execute 'highlight CursorLine   guibg=' . l:bg_hl
  execute 'highlight CursorColumn guibg=' . l:bg_hl
  execute 'highlight ColorColumn  guibg=#292e42'
  execute 'highlight SignColumn   guifg=' . l:fg_dark . ' guibg=NONE'
  execute 'highlight VertSplit    guifg=' . l:blue    . ' guibg=NONE gui=bold'
  execute 'highlight WinSeparator guifg=' . l:blue    . ' guibg=NONE gui=bold'
  execute 'highlight Visual       guibg=' . l:bg_visual
  execute 'highlight Search       guifg=' . l:bg      . ' guibg=' . l:yellow
  execute 'highlight IncSearch    guifg=' . l:bg      . ' guibg=' . l:orange
  execute 'highlight CurSearch    guifg=' . l:bg      . ' guibg=' . l:orange
  execute 'highlight MatchParen   guifg=' . l:orange  . ' gui=bold,underline'
  execute 'highlight NonText      guifg=' . l:gutter
  execute 'highlight Whitespace   guifg=' . l:gutter
  execute 'highlight SpecialKey   guifg=' . l:gutter
  execute 'highlight Folded       guifg=' . l:blue    . ' guibg=' . l:bg_dark
  execute 'highlight FoldColumn   guifg=' . l:gutter  . ' guibg=NONE'

  " Statusline / tabline
  execute 'highlight StatusLine    guifg=' . l:fg      . ' guibg=' . l:bg_dark
  execute 'highlight StatusLineNC  guifg=' . l:fg_dark . ' guibg=' . l:bg_dark
  execute 'highlight TabLine       guifg=' . l:fg_dark . ' guibg=' . l:bg_dark
  execute 'highlight TabLineSel    guifg=' . l:bg      . ' guibg=' . l:blue . ' gui=bold'
  execute 'highlight TabLineFill   guibg=' . l:bg_dark

  " Popup / wildmenu / completion
  execute 'highlight Pmenu         guifg=' . l:fg      . ' guibg=' . l:bg_dark
  execute 'highlight PmenuSel      guifg=' . l:bg      . ' guibg=' . l:blue . ' gui=bold'
  execute 'highlight PmenuSbar     guibg=' . l:bg_hl
  execute 'highlight PmenuThumb    guibg=' . l:fg_dark
  execute 'highlight WildMenu      guifg=' . l:bg      . ' guibg=' . l:blue . ' gui=bold'

  " Diagnostics / messages
  execute 'highlight ErrorMsg      guifg=' . l:red
  execute 'highlight WarningMsg    guifg=' . l:yellow
  execute 'highlight ModeMsg       guifg=' . l:blue    . ' gui=bold'
  execute 'highlight Question      guifg=' . l:cyan
  execute 'highlight Title         guifg=' . l:magenta . ' gui=bold'
  execute 'highlight Directory     guifg=' . l:blue

  " Syntax
  execute 'highlight Comment       guifg=' . l:comment . ' gui=NONE'
  execute 'highlight Constant      guifg=' . l:orange
  execute 'highlight String        guifg=' . l:green
  execute 'highlight Character     guifg=' . l:green
  execute 'highlight Number        guifg=' . l:orange
  execute 'highlight Boolean       guifg=' . l:orange
  execute 'highlight Float         guifg=' . l:orange
  execute 'highlight Identifier    guifg=' . l:red
  execute 'highlight Function      guifg=' . l:blue
  execute 'highlight Statement     guifg=' . l:magenta
  execute 'highlight Conditional   guifg=' . l:magenta
  execute 'highlight Repeat        guifg=' . l:magenta
  execute 'highlight Label         guifg=' . l:magenta
  execute 'highlight Operator      guifg=' . l:teal
  execute 'highlight Keyword       guifg=' . l:magenta
  execute 'highlight Exception     guifg=' . l:magenta
  execute 'highlight PreProc       guifg=' . l:cyan
  execute 'highlight Include       guifg=' . l:cyan
  execute 'highlight Define        guifg=' . l:cyan
  execute 'highlight Macro         guifg=' . l:cyan
  execute 'highlight Type          guifg=' . l:yellow
  execute 'highlight StorageClass  guifg=' . l:yellow
  execute 'highlight Structure     guifg=' . l:yellow
  execute 'highlight Typedef       guifg=' . l:yellow
  execute 'highlight Special       guifg=' . l:purple
  execute 'highlight SpecialChar   guifg=' . l:purple
  execute 'highlight Tag           guifg=' . l:cyan
  execute 'highlight Delimiter     guifg=' . l:fg_dark
  execute 'highlight SpecialComment guifg=' . l:comment . ' gui=bold'
  execute 'highlight Todo          guifg=' . l:bg      . ' guibg=' . l:yellow . ' gui=bold'
  execute 'highlight Underlined    guifg=' . l:blue    . ' gui=underline'
  execute 'highlight Error         guifg=' . l:red
  execute 'highlight Ignore        guifg=' . l:gutter

  " Diff
  execute 'highlight DiffAdd     guibg=#283b4d'
  execute 'highlight DiffChange  guibg=#272d43'
  execute 'highlight DiffDelete  guifg=' . l:red1   . ' guibg=#3a273a'
  execute 'highlight DiffText    guibg=#394b70'

  " Spell
  execute 'highlight SpellBad   gui=undercurl guisp=' . l:red
  execute 'highlight SpellCap   gui=undercurl guisp=' . l:yellow
  execute 'highlight SpellLocal gui=undercurl guisp=' . l:cyan
  execute 'highlight SpellRare  gui=undercurl guisp=' . l:magenta

  " Cursor / selection
  execute 'highlight QuickFixLine guibg=' . l:bg_visual
endfunction

call s:TokyonightMoon()

" Re-apply on :colorscheme tokyonight-moon, e.g. after :hi clear
augroup TokyonightMoon
  autocmd!
  autocmd ColorScheme tokyonight-moon call s:TokyonightMoon()
augroup END

" =============================================================================
" Keymaps — kickstart init.lua + custom/keymaps.lua + which-key.lua parity
" =============================================================================

" Clear highlights with <Esc> (kickstart)
nnoremap <silent> <Esc> :nohlsearch<CR>

" Window navigation (kickstart <C-hjkl>)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Redo with U (custom/keymaps.lua)
nnoremap U <C-r>
xnoremap U <C-r>

" Display-line motion: gj/gk on bare j/k, logical j/k when prefixed with count
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'

" Mousewheel-style viewport scroll on J/K (rebound from default)
nnoremap J 2<C-e>
nnoremap K 2<C-y>
xnoremap J 2<C-e>
xnoremap K 2<C-y>

" Insert-mode escape shortcuts
inoremap jk <Esc>
inoremap kj <Esc>
inoremap jj <Esc>

" Comment with <C-c> (uses vim-commentary)
nmap <C-c> gcc
xmap <C-c> gc

" Indent / unindent in normal mode (stay on current line)
nnoremap < <<
nnoremap > >>

" Helix-style line ends
nnoremap gh 0
nnoremap gl $
xnoremap gh 0
xnoremap gl $

" Select all
nnoremap gV ggVG

" Q quits everything (kickstart custom)
nnoremap Q :qa<CR>

" =============================================================================
" Leader bindings (which-key.lua parity)
" =============================================================================

" Top-level
nnoremap <silent> <Leader>c :bdelete<CR>
nnoremap <silent> <Leader>C :bdelete!<CR>
nnoremap <silent> <Leader>n :enew<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>Q :qa<CR>
nnoremap <silent> <Leader>s :w<CR>

" Rehomed J/K
nnoremap <Leader>J J
xnoremap <Leader>J J
nnoremap <Leader>K K
" (vim's K opens man/keywordprg lookup; in nvim this is LSP hover)

" --- Window (<Leader>w) ------------------------------------------------------
nnoremap <silent> <Leader>ws :split<CR>
nnoremap <silent> <Leader>wv :vsplit<CR>
nnoremap <silent> <Leader>wc :close<CR>
nnoremap <silent> <Leader>wo :only<CR>
nnoremap <silent> <Leader>w= <C-w>=
nnoremap <silent> <Leader>w+ :resize +5<CR>
nnoremap <silent> <Leader>w- :resize -5<CR>
nnoremap <silent> <Leader>w> :vertical resize +5<CR>
nnoremap <silent> <Leader>w< :vertical resize -5<CR>
nnoremap <silent> <Leader>wH <C-w>H
nnoremap <silent> <Leader>wJ <C-w>J
nnoremap <silent> <Leader>wK <C-w>K
nnoremap <silent> <Leader>wL <C-w>L
nnoremap <silent> <Leader>wr <C-w>r
nnoremap <silent> <Leader>wx <C-w>x

" --- Tabs (<Leader><Tab>) ----------------------------------------------------
nnoremap <silent> <Leader><Tab>n :tabnew<CR>
nnoremap <silent> <Leader><Tab>c :tabclose<CR>
nnoremap <silent> <Leader><Tab>o :tabonly<CR>
nnoremap <silent> <Leader><Tab>] :tabnext<CR>
nnoremap <silent> <Leader><Tab>[ :tabprevious<CR>
nnoremap <silent> <Leader><Tab>l :tablast<CR>
nnoremap <silent> <Leader><Tab>f :tabfirst<CR>
nnoremap <silent> <Leader><Tab>> :+tabmove<CR>
nnoremap <silent> <Leader><Tab>< :-tabmove<CR>

" --- Buffer (<Leader>b) ------------------------------------------------------
nnoremap <silent> <Leader>bn :bnext<CR>
nnoremap <silent> <Leader>bp :bprevious<CR>
nnoremap <silent> <Leader>bd :bdelete<CR>

" --- Find / pickers (<Leader>f, <Leader><Space>, <Leader>/) — fzf.vim --------
nnoremap <silent> <Leader><Space> :Buffers<CR>
nnoremap <silent> <Leader>ff :Files<CR>
nnoremap <silent> <Leader>fb :Buffers<CR>
nnoremap <silent> <Leader>fr :History<CR>
nnoremap <silent> <Leader>fg :Rg<CR>
nnoremap <silent> <Leader>fw :Rg <C-r><C-w><CR>
nnoremap <silent> <Leader>fh :Helptags<CR>
nnoremap <silent> <Leader>fk :Maps<CR>
nnoremap <silent> <Leader>fc :Commands<CR>
nnoremap <silent> <Leader>f. :History<CR>
nnoremap <silent> <Leader>f/ :Lines<CR>
nnoremap <silent> <Leader>/ :BLines<CR>

" --- Git (<Leader>g) — fugitive ----------------------------------------------
nnoremap <silent> <Leader>gg :Git<CR>
nnoremap <silent> <Leader>gb :Git blame<CR>
nnoremap <silent> <Leader>gd :Gdiffsplit<CR>
nnoremap <silent> <Leader>gl :Git log<CR>
nnoremap <silent> <Leader>gs :Git status<CR>

" --- Explorer (<Leader>e) — netrw stand-in for neo-tree ----------------------
nnoremap <silent> <Leader>ee :Explore<CR>
nnoremap <silent> <Leader>eo :Sexplore<CR>
nnoremap <silent> <Leader>ev :Vexplore<CR>

" Netrw cosmetic tweaks
let g:netrw_banner = 0          " no header
let g:netrw_liststyle = 3       " tree view
let g:netrw_winsize = 25        " 25% width when split

" =============================================================================
" Toggles (<Leader>t) — subset of toggles.lua that makes sense in plain vim
" =============================================================================
nnoremap <silent> <Leader>tw :setlocal wrap! linebreak!<Bar>set wrap?<CR>
nnoremap <silent> <Leader>tn :setlocal number!<Bar>set number?<CR>
nnoremap <silent> <Leader>tr :setlocal relativenumber!<Bar>set relativenumber?<CR>
nnoremap <silent> <Leader>ts :setlocal spell!<Bar>set spell?<CR>
nnoremap <silent> <Leader>tS :let &conceallevel = &conceallevel == 0 ? 2 : 0<Bar>set conceallevel?<CR>
nnoremap <silent> <Leader>tl :let &colorcolumn = &colorcolumn == '' ? '100' : ''<Bar>set colorcolumn?<CR>

" =============================================================================
" Filetype autocmds (custom/options.lua parity)
" =============================================================================
augroup CustomFiletypes
  autocmd!
  " Markdown: show all syntax characters
  autocmd FileType markdown setlocal conceallevel=0
  " Text-style files: enable soft wrap with linebreak
  autocmd FileType markdown,text,rst,tex setlocal wrap linebreak
  " Two-space indent for common web/config files
  autocmd FileType javascript,typescript,json,yaml,html,css,lua,vim setlocal sw=2 sts=2 ts=2
augroup END

" =============================================================================
" Highlight on yank (kickstart parity, vim 8+)
" Briefly highlights the yanked range with IncSearch.
" =============================================================================
function! s:HighlightYank() abort
  if v:event.operator !=# 'y' | return | endif
  let l:start = line("'[")
  let l:end = line("']")
  if l:start <= 0 || l:end <= 0 | return | endif
  let l:lines = []
  for l:i in range(l:start, l:end) | call add(l:lines, l:i) | endfor
  let l:m = matchaddpos('IncSearch', l:lines)
  call timer_start(150, {-> execute('silent! call matchdelete(' . l:m . ')')})
endfunction

if exists('##TextYankPost')
  augroup HighlightYank
    autocmd!
    autocmd TextYankPost * call s:HighlightYank()
  augroup END
endif

" =============================================================================
" fzf.vim cosmetics
" =============================================================================
let g:fzf_layout = { 'down': '40%' }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" vim: ts=2 sts=2 sw=2 et
