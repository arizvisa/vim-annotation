""" Text-properties / Virtual-text test for annotation of plaintext files.
""" XXX: This is _very_ preliminary and still being experimented with.

if exists('g:loaded_annotation') && g:loaded_annotation
  finish
elseif !has('textprop')
  echohl WarningMsg | echomsg printf("Refusing to load the annotation.vim plugin due to the host editor missing the \"%s\" feature.", 'textprop') | echohl None
  finish
endif
let g:loaded_annotation = v:true

""" FIXME: the things in this script need to be renamed and refactored into
"""        their own autoload library as the `annotation#frontend` namespace.
let g:annotation#property = 'annotation'
call prop_type_add(g:annotation#property, {'highlight': 'DiffText', 'override': v:true})

" Set up the required autocmds so that we can track the annotations that are
" associated with each buffer being viewed or edited.
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
