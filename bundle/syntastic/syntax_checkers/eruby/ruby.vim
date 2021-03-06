"============================================================================
"File:        ruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_eruby_ruby_checker")
    finish
endif
let g:loaded_syntastic_eruby_ruby_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_eruby_ruby_IsAvailable() dict
    if !exists('g:syntastic_eruby_ruby_exec') && exists('g:syntastic_ruby_exec')
        let g:syntastic_eruby_ruby_exec = g:syntastic_ruby_exec
    endif
    let s:exe = self.getExec()

    if executable(s:exe)
        let s:exe = syntastic#util#shescape(s:exe)
        if !syntastic#util#isRunningWindows()
            let s:exe = 'RUBYOPT= ' . s:exe
        endif
        return 1
    endif

    return 0
endfunction

function! SyntaxCheckers_eruby_ruby_GetLocList() dict
    let fname = "'" . escape(expand('%'), "\\'") . "'"

    " TODO: encodings became useful in ruby 1.9 :)
    if syntastic#util#versionIsAtLeast(syntastic#util#getVersion(s:exe . ' --version'), [1, 9])
        let enc = &fileencoding != '' ? &fileencoding : &encoding
        let encoding_spec = ', :encoding => "' . (enc ==? 'utf-8' ? 'UTF-8' : 'BINARY') . '"'
    else
        let encoding_spec = ''
    endif

    "gsub fixes issue #7, rails has it's own eruby syntax
    let makeprg =
        \ s:exe . ' -rerb -e ' .
        \ syntastic#util#shescape('puts ERB.new(File.read(' .
        \     fname . encoding_spec .
        \     ').gsub(''<%='',''<%''), nil, ''-'').src') .
        \ ' | ' . s:exe . ' -c'

    let errorformat =
        \ '%-GSyntax OK,'.
        \ '%E-:%l: syntax error\, %m,%Z%p^,'.
        \ '%W-:%l: warning: %m,'.
        \ '%Z%p^,'.
        \ '%-C%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': { 'bufnr': bufnr(""), 'vcol': 1 } })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'eruby',
    \ 'name': 'ruby'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
