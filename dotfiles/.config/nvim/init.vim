" :General: Notes
"
" Author: Samuel Roeca
" Date: August 15, 2017
" TLDR: vimrc minimum viable product for Python programming
"
" I've noticed that many vim/neovim beginners have trouble creating a useful
" vimrc. This file is intended to get a Python programmer who is new to vim
" set up with a vimrc that will enable the following:
"   1. Sane editing of Python files
"   2. Sane defaults for vim itself
"   3. An organizational skeleton that can be easily extended
"
" Notes:
"   * When in normal mode, scroll over a folded section and type 'za'
"       this toggles the folded section
"
" Initialization:
"   1. Follow instructions at https://github.com/junegunn/vim-plug to install
"      vim-plug for either Vim or Neovim
"   2. Open vim (hint: type vim at command line and press enter :p)
"   3. :PlugInstall
"   4. :PlugUpdate
"   5. You should be ready for MVP editing
"
" Updating:
"   If you want to upgrade your vim plugins to latest version
"     :PlugUpdate
"   If you want to upgrade vim-plug itself
"     :PlugUpgrade
" General: Leader mappings {{{

let mapleader = ","
let maplocalleader = "\\"

" }}}
" General: global config {{{

" Code Completion:
set completeopt=menuone,longest,preview
set wildmode=longest,list,full
set wildmenu

" Hidden Buffer: enable instead of having to write each buffer
set hidden

" Mouse: enable GUI mouse support in all modes
set mouse=a

" SwapFiles: prevent their creation
set nobackup
set noswapfile

" Line Wrapping: do not wrap lines by default
set nowrap

" Highlight Search:
set incsearch
set inccommand=nosplit
augroup sroeca_incsearch_highlight
    autocmd!
    autocmd CmdlineEnter /,\? set hlsearch
    autocmd CmdlineLeave /,\? set nohlsearch
augroup END

filetype plugin indent on

" Spell Checking:
set dictionary=$HOME/.american-english-with-propcase.txt
set spelllang=en_us

" Single Space After Punctuation: useful when doing :%j (the opposite of gq)
set nojoinspaces

set showtabline=2

set autoread

set grepprg=rg\ --vimgrep

" Paste: this is actually typed <C-/>, but term nvim thinks this is <C-_>
set pastetoggle=<C-_>

set notimeout   " don't timeout on mappings
set ttimeout    " do timeout on terminal key codes

" Local Vimrc: If exrc is set, the current directory is searched for 3 files
" in order (Unix), using the first it finds: '.nvimrc', '_nvimrc', '.exrc'
set exrc

" Default Shell:
set shell=$SHELL

" Numbering:
set number

" Window Splitting: Set split settings (options: splitright, splitbelow)
set splitright

" Redraw Window:
augroup redraw_on_refocus
    autocmd!
    autocmd FocusGained * redraw!
augroup END

" Terminal Color Support: only set guicursor if truecolor
if $COLORTERM ==# 'truecolor'
    set termguicolors
else
    set guicursor=
endif

set colorcolumn=80

" Default Background:
set background=dark

" Lightline: specifics for Lightline
set laststatus=2
set ttimeoutlen=50
set noshowmode

" ShowCommand: turn off character printing to vim status line
set noshowcmd

" Configure Updatetime: time Vim waits to do something after I stop moving
set updatetime=300

" SignColumn: displays signs in the number column
set signcolumn=number

" Linux Dev Path: system libraries
set path+=/usr/include/x86_64-linux-gnu/

" Python Provider: directing NeoVim to asdf managed Python 3 Provider
let g:python3_host_prog = "$HOME/.asdf/shims/python"
let g:loaded_python_provider = 0

augroup custom_filetype_recognition
  autocmd!
  autocmd BufEnter *.asm set filetype=nasm
  autocmd BufEnter *.cfg,*.ini,.coveragerc,*pylintrc,zoomus.conf set filetype=dosini
  autocmd BufEnter *.config,.cookiecutterrc set filetype=yaml
  autocmd BufEnter *.handlebars set filetype=html
  autocmd BufEnter *.hql,*.q set filetype=hive
  autocmd BufEnter *.js,*.gs set filetype=javascript
  autocmd BufEnter *mdx set filetype=markdown
  autocmd BufEnter *.min.js set filetype=none
  autocmd BufEnter *.m,*.oct set filetype=octave
  autocmd BufEnter *.py.j2 set filetype=python.jinja2
  autocmd BufEnter *.sql.j2 set filetype=sql.jinja2
  autocmd BufEnter *.toml set filetype=toml
  autocmd BufEnter *.tsv set filetype=tsv
  autocmd BufEnter .envrc set filetype=sh
  autocmd BufEnter .gitignore,.dockerignore set filetype=conf
  autocmd BufEnter .jrnl_config,*.bowerrc,*.babelrc,*.eslintrc,*.slack-term set filetype=json
  autocmd BufEnter Dockerfile.* set filetype=dockerfile
  autocmd BufEnter Makefile.* set filetype=make
  autocmd BufEnter poetry.lock,Pipfile set filetype=toml
  autocmd BufEnter tsconfig.json,*.jsonc,.markdownlintrc set filetype=jsonc
  autocmd BufEnter .zshrc set filetype=sh
augroup end

" CustomColumns: different columns depending on filetype
augroup custom_colorcolumn
  autocmd!
  autocmd FileType gitcommit setlocal colorcolumn=73 textwidth=72
  autocmd Filetype html,text,markdown,rst,fzf setlocal colorcolumn=0
augroup end

" Folds: Allowing for folds in long dotfiles
augroup custom_fold_settings
  autocmd!
  autocmd FileType vim,tmux,bash,zsh,sh setlocal foldenable foldmethod=marker foldnestmax=1
  autocmd FileType markdown,rst setlocal nofoldenable
  autocmd FileType yaml setlocal nofoldenable foldmethod=indent foldnestmax=1
augroup end

function! s:trim_whitespace()
  let l:save = winsaveview()
  if &ft == 'markdown'
    " Replace lines with only trailing spaces
    %s/^\s\+$//e
    " Replace lines with exactly one trailing space with no trailing spaces
    %g/\S\s$/s/\s$//g
    " Replace lines with more than 2 trailing spaces with 2 trailing spaces
    %s/\s\s\s\+$/  /e
  else
    " Remove all trailing spaces
    %s/\s\+$//e
  endif
  call winrestview(l:save)
endfunction

command! TrimWhitespace call s:trim_whitespace()

augroup custom_fix_whitespace_save
  autocmd!
  autocmd BufWritePre * TrimWhitespace
augroup end

" Configure clipboard explicitly. Speeds up startup
let g:clipboard = {
      \ 'name': 'xsel',
      \ 'copy': {
      \    '+': 'xsel --clipboard --input',
      \    '*': 'xsel --clipboard --input',
      \  },
      \ 'paste': {
      \    '+': 'xsel --clipboard --output',
      \    '*': 'xsel --clipboard --output',
      \ },
      \ 'cache_enabled': 0,
      \ }

" }}}
" General: Plugin Install {{{

call plug#begin('~/.vim/plugged')

" Help for vim-plug
Plug 'junegunn/vim-plug'

" Make tabline prettier
Plug 'kh3phr3n/tabline'

" Commands run in vim's virtual screen and don't pollute main shell
Plug 'fcpg/vim-altscreen'

" Basic coloring
Plug 'pappasam/papercolor-theme-slim'

" Code Formatting
Plug 'pappasam/vim-filetype-formatter'

" Utils
Plug 'tpope/vim-commentary'

" Language-specific syntax
Plug 'vim-python/python-syntax'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

" Indentation
Plug 'Vimjas/vim-python-pep8-indent'

" NerdTree
Plug 'preservim/nerdtree'|
            \ Plug 'Xuyuanp/nerdtree-git-plugin'

" DevIcons
Plug 'ryanoasis/vim-devicons'

" NERDTreeSyntaxHighlighting
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Coc
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

call plug#end()

" }}}
" General: Status Line and Tab Line {{{

" Tab Line:
set tabline=%t

" Status Line:
set laststatus=2
set statusline=
set statusline+=\ %{mode()}\  " spaces after mode
set statusline+=%#CursorLine#
set statusline+=\   " space
set statusline+=%{&paste?'[PASTE]':''}
set statusline+=%{&spell?'[SPELL]':''}
set statusline+=%r
set statusline+=%m
set statusline+=%{get(b:,'gitbranch','')}
set statusline+=\   " space
set statusline+=%*  " Default color
set statusline+=\ %f
set statusline+=%=
set statusline+=%n  " buffer number
set statusline+=\ %y\  " File type
set statusline+=%#CursorLine#
set statusline+=\ %{&ff}\  " Unix or Dos
set statusline+=%*  " Default color
set statusline+=\ %{strlen(&fenc)?&fenc:'none'}\  " file encoding
augroup statusline_local_overrides
    autocmd!
    autocmd FileType nerdtree setlocal statusline=\ NERDTree\ %#CursorLine#
augroup END

" Strip newlines from a string
function! StripNewlines(instring)
    return substitute(a:instring, '\v^\n*(.{-})\n*$', '\1', '')
endfunction

function! StatuslineGitBranch()
    let b:gitbranch = ''
    if &modifiable
        try
            let branch_name = StripNewlines(system(
                        \ 'git -C ' .
                        \ expand('%:p:h') .
                        \ ' rev-parse --abbrev-ref HEAD'))
            if !v:shell_error
                let b:gitbranch = '[git::' . branch_name . ']'
            endif
        catch
        endtry
    endif
endfunction

augroup get_git_branch
    autocmd!
    autocmd VimEnter,WinEnter,BufEnter * call StatuslineGitBranch()
augroup END

" }}}
" General: Indentation (tabs, spaces, width, etc) {{{

augroup custom_indentation
  autocmd!
  " 4 spaces per tab, not 2
  autocmd Filetype python,c,haskell,rust,kv,nginx,asm,nasm,gdscript3 setlocal shiftwidth=4 softtabstop=4
  " Use hard tabs, not spaces
  autocmd Filetype make,tsv,votl,go,gomod setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
  " Prevent auto-indenting from occuring
  autocmd Filetype yaml setlocal indentkeys-=<:>
augroup end


" }}}
" General: Folding Settings {{{

augroup fold_settings
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
  autocmd FileType vim setlocal foldlevelstart=0
  autocmd FileType * setlocal foldnestmax=1
augroup END

" }}}
" General: Trailing whitespace {{{

" This section should go before syntax highlighting
" because autocommands must be declared before syntax library is loaded
function! TrimWhitespace()
  if &ft == 'markdown'
    return
  endif
  let l:save = winsaveview()
  %s/\s\+$//e
  call winrestview(l:save)
endfunction

highlight EOLWS ctermbg=red guibg=red
match EOLWS /\s\+$/
augroup whitespace_color
  autocmd!
  autocmd ColorScheme * highlight EOLWS ctermbg=red guibg=red
  autocmd InsertEnter * highlight EOLWS NONE
  autocmd InsertLeave * highlight EOLWS ctermbg=red guibg=red
augroup END

augroup fix_whitespace_save
  autocmd!
  autocmd BufWritePre * call TrimWhitespace()
augroup END

" }}}
" General: Syntax highlighting {{{
try
  colorscheme PaperColorSlim
catch
  echo 'An error occured while configuring PaperColor'
endtry

" }}}
" General: key mappings {{{

let mapleader = ','

function! s:default_key_mappings()
  " Coc: settings for coc.nvim
  nmap     <silent>        <C-]> <Plug>(coc-definition)
  nnoremap <silent>        <C-k> <Cmd>call CocActionAsync('doHover')<CR>
  inoremap <silent>        <C-s> <Cmd>call CocActionAsync('showSignatureHelp')<CR>
  nnoremap <silent>        <C-w>f <Cmd>call coc#float#jump()<CR>
  nmap     <silent>        <leader>st <Plug>(coc-type-definition)
  nmap     <silent>        <leader>si <Plug>(coc-implementation)
  nmap     <silent>        <leader>su <Plug>(coc-references)
  nmap     <silent>        <leader>sr <Plug>(coc-rename)
  nmap     <silent>        <leader>sa v<Plug>(coc-codeaction-selected)
  vmap     <silent>        <leader>sa <Plug>(coc-codeaction-selected)
  nnoremap <silent>        <leader>sn <Cmd>CocNext<CR>
  nnoremap <silent>        <leader>sp <Cmd>CocPrev<CR>
  nnoremap <silent>        <leader>sl <Cmd>CocListResume<CR>
  nnoremap <silent>        <leader>sc <Cmd>CocList commands<cr>
  nnoremap <silent>        <leader>so <Cmd>CocList -A outline<cr>
  nnoremap <silent>        <leader>sw <Cmd>CocList -A -I symbols<cr>
  inoremap <silent> <expr> <c-space> coc#refresh()
  nnoremap                 <leader>d <Cmd>call CocActionAsync('diagnosticToggle')<CR>
  nnoremap                 <leader>D <Cmd>call CocActionAsync('diagnosticPreview')<CR>
  nmap     <silent>        ]g <Plug>(coc-diagnostic-next)
  nmap     <silent>        [g <Plug>(coc-diagnostic-prev)

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  " Insert <tab> when previous text is space, refresh completion if not.
  inoremap <silent><expr> <TAB>
	\ coc#pum#visible() ? coc#pum#next(1):
	\ <SID>check_back_space() ? "\<Tab>" :
	\ coc#refresh()
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

  " Toggle gitsigns
  nnoremap <silent> <leader>g <Cmd>GitsignsToggle<CR>

  " Escape: also clears highlighting
  nnoremap <silent> <esc> <Cmd>noh<return><esc>

  " J: unmap in normal mode unless range explicitly specified
  nnoremap <silent> <expr> J v:count == 0 ? '<esc>' : 'J'

  " SearchBackward: remap comma to single quote
  nnoremap ' ,

  " Go to tab by number
  noremap <leader>1 1gt
  noremap <leader>2 2gt
  noremap <leader>3 3gt
  noremap <leader>4 4gt
  noremap <leader>5 5gt
  noremap <leader>6 6gt
  noremap <leader>7 7gt
  noremap <leader>8 8gt
  noremap <leader>9 9gt
  noremap <leader>0 :tablast<cr>

  " Navigate tabs with 'h' and 'l'
  nnoremap <C-h> :tabprevious<CR>
  nnoremap <C-l> :tabnext<CR>

  " MoveVisual: up and down visually only if count is specified before
  nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
  vnoremap <expr> k v:count == 0 ? 'gk' : 'k'
  nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
  vnoremap <expr> j v:count == 0 ? 'gj' : 'j'

  " jk escapes
  inoremap jk <esc>

  "Close tab
  inoremap <C-S> :wq
  inoremap <C-s> :q

  " TogglePluginWindows:
  nnoremap <silent> <space>J <Cmd>NERDTreeToggle<CR>
  nnoremap <silent> <space>l <Cmd>call <SID>coc_toggle_outline()<CR>

  " IndentLines: toggle if indent lines is visible
  nnoremap <silent> <leader>i <Cmd>IndentLinesToggle<CR>

  " Telescope: create shortcuts for finding stuff
  nnoremap <silent> <C-p><C-p> <Cmd>Telescope find_files hidden=true<CR>
  nnoremap <silent> <C-p><C-b> <Cmd>Telescope buffers<CR>
  nnoremap <silent> <C-n><C-n> <Cmd>Telescope live_grep<CR>
  nnoremap <silent> <C-n><C-w> <Cmd>Telescope grep_string<CR>

  " FiletypeFormat: remap leader f to do filetype formatting
  nnoremap <silent> <leader>f <Cmd>FiletypeFormat<cr>
  vnoremap <silent> <leader>f :FiletypeFormat<cr>

  " Open GitHub ssh url
  nnoremap gx <Cmd>call <SID>gx_improved()<CR>

  " Clipboard Copy: Visual mode copy is pretty simple
  vnoremap <leader>y "+y
  nnoremap <leader>y "+y

  " Markdown Preview
  nmap <silent> <C-s> <Plug>MarkdownPreview

  " Auto-execute all filetypes
  let &filetype=&filetype

endfunction

call s:default_key_mappings()

augroup custom_remap_man_help
  autocmd!
  autocmd FileType man,help nnoremap <buffer> <silent> <C-]> <C-]>
augroup end

augroup custom_remap_nvim_tree_lua
  autocmd!
  autocmd FileType NvimTree nnoremap <buffer> <silent> <C-l> <Cmd>NvimTreeResize +2<CR>
  autocmd FileType NvimTree nnoremap <buffer> <silent> <C-h> <Cmd>NvimTreeResize -2<CR>
augroup end

" }}}
"  Plugin: Configure {{{

" Python highlighting
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1

" Coc:
let g:coc_snippet_next = '<C-j>'
let g:coc_snippet_prev = '<C-k>'
let g:coc_start_at_startup = 1
let g:coc_filetype_map = {
      \ 'python.jinja2': 'python',
      \ 'sql.jinja2': 'sql',
      \ 'markdown.mdx': 'markdown',
      \ 'yaml.ansible': 'yaml',
      \ 'yaml.docker-compose': 'yaml',
      \ 'jinja.html': 'html',
      \ }

" Vim-Filetype
let g:vim_filetype_formatter_verbose = 1
let g:vim_filetype_formatter_commands = {
      \ 'python': 'poetry run black - -q --line-length 79',
      \ 'javascript': 'npx -q prettier --parser flow',
      \ 'javascript.jsx': 'npx -q prettier --parser flow',
      \ 'typescript': 'npx -q prettier --parser typescript',
      \ 'typescript.tsx': 'npx -q prettier --parser typescript',
      \ 'css': 'npx -q prettier --parser css',
      \ 'less': 'npx -q prettier --parser less',
      \ 'html': 'npx -q prettier --parser html',
      \ 'typescriptreact': 'npx -q prettier --parser typescript',
      \ 'vue': 'npx -q prettier --html-whitespace-sensitivity ignore --parser vue --stdin'
      \}

" Coc Global Extensions: automatically installed on Vim open
let g:coc_global_extensions = [
      \ '@yaegassy/coc-nginx',
      \ 'coc-angular',
      \ 'coc-css',
      \ 'coc-diagnostic',
      \ 'coc-dictionary',
      \ 'coc-docker',
      \ 'coc-emoji',
      \ 'coc-go',
      \ 'coc-html',
      \ 'coc-java',
      \ 'coc-json',
      \ 'coc-lists',
      \ 'coc-markdownlint',
      \ 'coc-rls',
      \ 'coc-sh',
      \ 'coc-snippets',
      \ 'coc-svelte',
      \ 'coc-svg',
      \ 'coc-syntax',
      \ 'coc-texlab',
      \ 'coc-toml',
      \ 'coc-tsserver',
      \ 'coc-vimlsp',
      \ 'coc-word',
      \ 'coc-yaml',
      \ 'coc-yank',
      \ 'coc-pyright',
      \ ]

function! s:autocmd_custom_coc()
  if !exists("g:did_coc_loaded")
    return
  endif
  augroup custom_coc
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    " Coc nvim might override my mappings. I call them again just in case.
    autocmd User CocNvimInit call s:default_key_mappings()
  augroup end
endfunction

augroup custom_coc
  autocmd!
  autocmd VimEnter * call s:autocmd_custom_coc()
  autocmd User CocNvimInit * call s:default_key_mappings()
augroup end

augroup custom_coc_additional_keyword_characters
  autocmd!
  autocmd FileType nginx let b:coc_additional_keywords = ['$']
augroup end

let g:mkdp_auto_start = v:false
let g:mkdp_auto_close = v:false
let g:mkdp_refresh_slow = 1
let g:mkdp_command_for_global = 0
let g:mkdp_browser = ''
let g:mkdp_preview_options = {
      \ 'mkit': {},
      \ 'katex': {},
      \ 'uml': {},
      \ 'maid': {},
      \ 'disable_sync_scroll': 0,
      \ 'sync_scroll_type': 'middle'
      \ }
let g:mkdp_markdown_css = expand("~/github-markdown.css")
let g:mkdp_port = ''
let g:mkdp_page_title = '「${name}」'
let g:mkdp_filetypes = ['markdown']

function! s:preview()
  if &filetype ==? 'rst'
    silent exec 'terminal restview %'
    silent exec "normal \<C-O>"
  elseif &filetype ==? 'markdown'
    " from markdown-preview.vim
    silent exec 'MarkdownPreview'
  elseif &filetype ==? 'plantuml'
    " from plantuml-previewer.vim
    silent exec 'PlantumlOpen'
  else
    silent !gio open '%:p'
  endif
endfunction
" NERDTree:
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
"  }}}
" General: Cleanup {{{
" commands that need to run at the end of my vimrc

" disable unsafe commands in your project-specific .vimrc files
" This will prevent :autocmd, shell and write commands from being
" run inside project-specific .vimrc files unless they’re owned by you.
set secure

" }}}
