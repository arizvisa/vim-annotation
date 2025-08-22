""" The functions within this specific module provide the entirety of the
""" interface that the user will see. The terrible organization of this module
""" is due to the scoping requirements of vimscript and its menu callbacks.

" Show the modification menu for the specified annotation.
function! s:modify_annotation_item(bufnum, property)
  let property = annotation#state#getprop(a:bufnum, a:property.id)
  call annotation#menu#modify(property)
endfunction

" Add a new annotation for the specified visual block.
function! s:add_annotation_visual(bufnum, lnum, col, end_lnum, end_col)
  let property = annotation#frontend#add_property(a:bufnum, a:lnum, a:col, a:end_lnum, a:end_col)
  call annotation#menu#add(property)
endfunction

" Return the data for the annotation associated with the specified property.
function! s:get_annotation_data(property)
  let [property, data] = annotation#frontend#get_property_data(a:property.bufnr, a:property.lnum, a:property.col, a:property.id)
  let notes = exists('data.notes')? data.notes : {}

  let res = []
  for id in sort(keys(notes))
    call add(res, printf('%s: %s', 1 + len(res), notes[id]))
  endfor
  return res
endfunction

" Modify the annotation at the specified cursor position.
function! annotation#cursor_modify(bufnum, lnum, col)
  let property = annotation#property#get(a:bufnum, a:col, a:lnum, g:annotation#property)
  if empty(property)
    throw printf('annotation.MissingPropertyError: no property was found in buffer %d at line %d column %d.', a:bufnum, a:lnum, a:col)
  endif
  call s:modify_property_item(a:bufnum, property)
endfunction

" Remove the annotation at the specified cursor position.
function! annotation#cursor_remove(bufnum, lnum, col)
  let current = annotation#property#get(a:bufnum, a:col, a:lnum, g:annotation#property)
  if !empty(current)
    call annotation#frontend#del_property(a:bufnum, a:lnum, a:col, current['id'])
  endif
endfunction

" Display the annotation at the specified cursor position.
function! annotation#cursor_show(bufnum, lnum, col)
  call annotation#frontend#show_property_data(a:bufnum, a:lnum, a:col, funcref('s:get_annotation_data'))
endfunction

" Add or modify an annotation at the cursor position or visual-mode selection.
" FIXME: we should checking for overlapping properties just in case.
function! annotation#select(bufnum, y, x, lnum, col, end_lnum, end_col)
  let ids = annotation#state#find_bounds(a:bufnum, a:col, a:lnum, a:end_col, a:end_lnum)
  let properties = mapnew(ids, 'annotation#state#getprop(a:bufnum, v:val)')
  let current = annotation#property#get(a:bufnum, a:x, a:y, g:annotation#property)

  " If there is no text at the specified line number, then we throw up an error
  " since there's no content that can be selected. Currently we do not support
  " annotations spanning multiple lines.. when we do this code will need fixing.
  let content = getline(a:lnum)
  if empty(ids) && empty(current) && !strwidth(content) && a:lnum == a:end_lnum
    echohl ErrorMsg | echomsg printf("annotation.MissingContentError: unable to add an annotation due to line %d having no columns (%d).", a:lnum, strwidth(content)) | echohl None

  " If there are no annotations found, then go ahead and add a new one.
  elseif empty(ids) && empty(current)
    let maxcol = 1 + strwidth(getline(a:end_lnum))
    call s:add_annotation_visual(a:bufnum, a:lnum, a:col, a:end_lnum, min([a:end_col, maxcol]))

  " If there were some annotation ids, then we can go ahead and modify it.
  elseif !empty(current)
    call s:modify_annotation_item(a:bufnum, current)

  " Check the span of a single line to figure out the annotation to modify.
  elseif a:lnum == a:end_lnum
    let filtered = annotation#property#filter_by_span(properties, a:col, a:end_col, a:lnum)
    let property = filtered[0]
    call s:modify_annotation_item(a:bufnum, property)
  endif
endfunction

" Scan forward from the specified cursor position to the next annotation.
function! annotation#cursor_forward(bufnum, lnum, col)
  let [x, y] = annotation#property#scanforward(a:bufnum, a:col, a:lnum, g:annotation#property)
  if [a:col, a:lnum] != [x, y]
    let res = (cursor(y, x) < 0)? v:false : v:true
  else
    let res = v:false
  endif
  return res
endfunction

" Scan backward from the specified cursor position to the previous annotation.
function! annotation#cursor_backward(bufnum, lnum, col)
  let [x, y] = annotation#property#scanbackward(a:bufnum, a:col, a:lnum, g:annotation#property)
  if [a:col, a:lnum] != [x, y]
    let res = (cursor(y, x) < 0)? v:false : v:true
  else
    let res = v:false
  endif
  return res
endfunction

" Look through the currently loaded buffers and load any discovered annotations.
function! s:load_annotations_for_buffers()
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

" Set up the autocmds that are required to save and load annotations for a
" buffer that is currently being viewed or edited.
function! annotation#setup_persistence()
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
    autocmd SessionLoadPost * call s:load_annotations_for_buffers()

    " If vim is leaving, then try and save the current buffer.
    autocmd VimLeavePre * call annotation#frontend#save_buffer(expand('<abuf>'), expand('<afile>'))
  augroup END
endfunction
