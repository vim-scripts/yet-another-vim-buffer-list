function! <SID>Mapped(fn, l)
    let new_list = deepcopy(a:l)
    call map(new_list, string(a:fn) . '(v:val)')
    return new_list
endfunction

function! <SID>Filtered(fn, l)
    let new_list = deepcopy(a:l)
    call filter(new_list, string(a:fn) . '(v:val)')
    return new_list
endfunction

function! <SID>ToNumber(str)
    return 0 + a:str
endfunction

function! <SID>BufListedWrap(bufnum)
    return buflisted(a:bufnum)
endfunction

function! <SID>NotBufferList(bufnum)
    return bufname(a:bufnum) !=# '__BUFFER_LIST__'
endfunction

function! <SID>BufNumToDict(bufnum)
    return {'number': a:bufnum, 'name': bufname(a:bufnum)}
endfunction

function! <SID>GetBufferList()
    let high = bufnr('$')
    let all = range(1, high)
    let listed = <SID>Filtered(function('<SID>BufListedWrap'), all)
    let not_buf_list = <SID>Filtered(function('<SID>NotBufferList'), listed)
    let dicts = <SID>Mapped(function('<SID>BufNumToDict'), not_buf_list)
    return dicts
endfunction

function! <SID>BufferToListLine(bufdict)
    return a:bufdict.number . ' -- ' . a:bufdict.name
endfunction

function! <SID>ShowBufferList()
    vsplit __BUFFER_LIST__
    let buffers = <SID>GetBufferList()
    let lines = <SID>Mapped(function('<SID>BufferToListLine'), buffers)
    set ma
    normal! ggdG
    for line in lines
        execute 'normal! o' . line
    endfor
    set noma
    nnoremap <buffer> <cr> :call <SID>SelectBuffer()<cr>
    nnoremap <buffer> q :bd!<cr>
    nnoremap <buffer> d :call <SID>DeleteBufferAndRefreshBufferList()<cr>
endfunction

function! <SID>DeleteBufferAndRefreshBufferList()
    let bufferno = <SID>GetSelectedBuffer()
    execute ':bd' . bufferno
    bd!
    call <SID>ShowBufferList()
endfunction

function! <SID>GetSelectedBuffer()
    let lineno = getpos('.')[1]
    let line = getline(lineno)
    let parts = split(line, '--')
    let bufferno = <SID>ToNumber(parts[0])
    return bufferno
endfunction

function! <SID>SelectBuffer()
    let bufferno = <SID>GetSelectedBuffer()
    bd!
    execute ':b' . bufferno
endfunction

nnoremap <leader>0 :source ~/.vim/plugin/buflist.vim<cr>
nnoremap <leader>bl :call <SID>ShowBufferList()<cr>
