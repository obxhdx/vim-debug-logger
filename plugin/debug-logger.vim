function! s:PrintError(msg)
  let l:prefix = '[vim-debug-logger]'
  echohl ErrorMsg | echon l:prefix.' '.a:msg | echohl None
endfunction

if !exists('*MapAction')
  call s:PrintError('Missing dependency: obxhdx/vim-action-mapper')
  finish
endif

function! s:ExecuteKeepingCursorPosition(command)
  let l:saved_search_pattern = @/
  let l:saved_line = line('.')
  let l:saved_column = col('.')

  execute a:command

  let @/ = l:saved_search_pattern
  call cursor(l:saved_line, l:saved_column)
endfunction

function! DebugLog(text, ...)
  let l:prefix = 'DEBUG LOG'
  let l:metadata = '['.l:prefix.'] ['.expand('%:t').':'.line('.').']'
  let l:marker = '==>'

  let l:console_stmt = 'console.log("%s %s:", %s);'
  let l:echo_stmt = 'echo "%s %s: ${%s}"'
  let l:lua_print_stmt = 'print("%s %s: "..%s)'
  let l:print_stmt = 'print("%s %s:", %s)'
  let l:puts_stmt = 'puts ("%s %s: #{%s}")'
  let l:sout_stmt = 'System.out.println("%s %s: " + %s);'

  " TODO allow customization
  let l:template_map = {
        \ 'bash': l:echo_stmt,
        \ 'java': l:sout_stmt,
        \ 'javascript': l:console_stmt,
        \ 'javascript.jsx': l:console_stmt,
        \ 'javascriptreact': l:console_stmt,
        \ 'lua': l:lua_print_stmt,
        \ 'python': l:print_stmt,
        \ 'ruby': l:puts_stmt,
        \ 'sh': l:echo_stmt,
        \ 'typescript': l:console_stmt,
        \ 'typescript.jsx': l:console_stmt,
        \ 'typescriptreact': l:console_stmt,
        \ 'zsh': l:echo_stmt,
        \ }

  let l:log_expression = get(l:template_map, &ft, '')

  if empty(l:log_expression)
    call s:PrintError('Filetype "'.&ft.'" not suppported.')
    return
  endif

  execute "normal o" . printf(l:log_expression, l:metadata.' '.l:marker, a:text, a:text)
endfunction

" TODO
" CommentAllDebugLogs
" DeleteAllDebugLogs
" UncommentAllDebugLogs

if get(g:, 'debug_logger#disable_default_mappings')
  finish
endif

autocmd User MapActions call MapAction('DebugLog', '<leader>l')
