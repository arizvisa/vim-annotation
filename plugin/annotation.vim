""" Text-properties / Virtual-text test for annotation of plaintext files.
""" XXX: This is _very_ preliminary and still being experimented with.

if exists('g:loaded_annotation') && g:loaded_annotation
  finish
endif

" Check for the existence of any required Vim features
for s:feature in ['windows', 'textprop']
  if !has(s:feature)
    echohl WarningMsg | echomsg printf("Refusing to load the annotation.vim plugin due to the host editor missing the \"%s\" feature.", s:feature) | echohl None
    finish
  endif
endfor
let g:loaded_annotation = v:true

" Figure out the default options for the plugin, and then set up the required
" autocmds so that we can track the annotations for each buffer being viewed.
call annotation#setup_defaults()
call annotation#setup_persistence()

""" Define some mapping actions for users to customize their bindings with.
xmap <Plug>(annotation-visual-add) <Esc><Cmd>call annotation#select(bufnr(), line('.'), col('.'), getpos("'<")[1], getpos("'<")[2], getpos("'>")[1], 1 + getpos("'>")[2])<CR>
nmap <Plug>(annotation-line-add) <Esc><Cmd>call annotation#select(bufnr(), line('.'), col('.'), line('.'), 1 + match(getline('.'), '\S'), line('.'), col('$'))<CR>
nmap <Plug>(annotation-position-remove) <Cmd>call annotation#cursor_remove(bufnr(), getpos('.')[1], getpos('.')[2])<CR>
nmap <Plug>(annotation-position-show) <Cmd>call annotation#cursor_show(bufnr(), getpos('.')[1], getpos('.')[2])<CR>

nmap <Plug>(annotation-seek-backward) <Cmd>call annotation#cursor_backward(bufnr(), line('.'), col('.'))<CR>
nmap <Plug>(annotation-seek-forward) <Cmd>call annotation#cursor_forward(bufnr(), line('.'), col('.'))<CR>

""" Set some default mappings for interacting with annotations.
let mapleader = "\<C-m>"
if get(g:, 'annotation#bindings', v:true)
  xmap <Leader>n <Plug>(annotation-visual-add)
  nmap <Leader>n <Plug>(annotation-line-add)
  nmap <Leader>d <Plug>(annotation-position-remove)
  nmap <Leader>? <Plug>(annotation-position-show)

  nmap <Leader>[ <Plug>(annotation-seek-backward)
  nmap <Leader>] <Plug>(annotation-seek-forward)
  nmap <Leader><C-[> <Plug>(annotation-seek-backward)
  nmap <Leader><C-]> <Plug>(annotation-seek-forward)
endif
