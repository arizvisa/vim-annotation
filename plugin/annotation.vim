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
let g:annotation_property = 'annotation'

augroup annotations
  autocmd!

  " Managing the scope of a buffer by adding and removing the annotation state.
  autocmd BufRead * call annotation#frontend#add_buffer(expand('<abuf>'))
  autocmd BufAdd * call annotation#frontend#add_buffer(expand('<abuf>'))
  autocmd BufDelete * call annotation#frontend#del_buffer(expand('<abuf>'))

  " Loading and saving the annotations associated with a buffer.
  autocmd BufReadPost * call annotation#frontend#load_buffer(expand('<abuf>'), expand('<afile>'))
  autocmd BufWritePost * call annotation#frontend#save_buffer(expand('<abuf>'), expand('<afile>'))
  autocmd BufLeave * call annotation#frontend#save_buffer(expand('<abuf>'), expand('<afile>'))

  " Add the initial empty buffer that exists on startup.
  autocmd VimEnter * call annotation#frontend#add_buffer(expand('<abuf>'))
  autocmd SessionLoadPost * call s:LoadAnnotionsForBuffers()

  " If vim is leaving, then try and save the current buffer.
  autocmd VimLeavePre * call annotation#frontend#save_buffer(expand('<abuf>'), expand('<afile>'))
augroup END

call prop_type_add(g:annotation_property, {'highlight': 'DiffText', 'override': v:true})

function! s:LoadAnnotionsForBuffers()
  let filtered = []
  for bufinfo in getbufinfo()
    if exists('bufinfo.name')
      call add(filtered, bufinfo)
    endif
  endfor

  " Iterate through all of the buffers where we have a path, add if they don't
  " exist and then try to load them.
  for bufinfo in filtered
    if !bufloaded(bufinfo.bufnr)
      call bufload(bufinfo.bufnr)
    endif
    if bufloaded(bufinfo.bufnr)
      call annotation#frontend#load_buffer(bufinfo.bufnr, bufinfo.name)
    endif
  endfor
endfunction

""" Define some mapping actions for users to customize their bindings with.
xmap <Plug>(annotation-visual-add) <Esc><Cmd>call annotation#select(bufnr(), line('.'), col('.'), getpos("'<")[1], getpos("'<")[2], getpos("'>")[1], 1 + getpos("'>")[2])<CR>
nmap <Plug>(annotation-line-add) <Esc><Cmd>call annotation#select(bufnr(), line('.'), col('.'), line('.'), 1 + match(getline('.'), '\S'), line('.'), col('$'))<CR>
nmap <Plug>(annotation-position-remove) <Cmd>call annotation#cursor_remove(bufnr(), getpos('.')[1], getpos('.')[2])<CR>
nmap <Plug>(annotation-position-show) <Cmd>call annotation#cursor_show(bufnr(), getpos('.')[1], getpos('.')[2])<CR>

nmap <Plug>(annotation-seek-backward) <Cmd>call annotation#cursor_backward(bufnr(), line('.'), col('.'))<CR>
nmap <Plug>(annotation-seek-forward) <Cmd>call annotation#cursor_forward(bufnr(), line('.'), col('.'))<CR>

""" Set some default mappings for interacting with annotations.
let mapleader = "\<C-m>"
xmap <Leader>n <Plug>(annotation-visual-add)
nmap <Leader>n <Plug>(annotation-line-add)
nmap <Leader>d <Plug>(annotation-position-remove)
nmap <Leader>? <Plug>(annotation-position-show)

nmap <Leader>[ <Plug>(annotation-seek-backward)
nmap <Leader>] <Plug>(annotation-seek-forward)
nmap <Leader><C-[> <Plug>(annotation-seek-backward)
nmap <Leader><C-]> <Plug>(annotation-seek-forward)
