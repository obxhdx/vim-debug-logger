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

let s:log_prefix = 'DEBUG LOG'
let s:log_marker = '==>'

function! DebugLog(variable_name, ...)
  let l:bash_echo_stmt = 'echo "%s: ${%s}"'
  let l:console_stmt = 'console.log("%s:", %s);'
  let l:lua_print_stmt = 'print("%s: "..%s)'
  let l:print_stmt = 'print("%s:", %s)'
  let l:puts_stmt = 'puts ("%s: #{%s}")'
  let l:sout_stmt = 'System.out.println("%s: " + %s);'
  let l:vim_echo_stmt = 'echo "%s: ".%s'

  let l:log_metadata = '['.s:log_prefix.'] ['.expand('%:t').':'.line('.').']'

  let l:template_map = {
        \ 'bash': l:bash_echo_stmt,
        \ 'java': l:sout_stmt,
        \ 'javascript': l:console_stmt,
        \ 'javascript.jsx': l:console_stmt,
        \ 'javascriptreact': l:console_stmt,
        \ 'lua': l:lua_print_stmt,
        \ 'python': l:print_stmt,
        \ 'ruby': l:puts_stmt,
        \ 'sh': l:bash_echo_stmt,
        \ 'typescript': l:console_stmt,
        \ 'typescript.jsx': l:console_stmt,
        \ 'typescriptreact': l:console_stmt,
        \ 'vim': l:vim_echo_stmt,
        \ 'zsh': l:bash_echo_stmt,
        \ }

  call extend(l:template_map, get(g:, 'debug_logger_template_map', {}))

  let l:template_string = get(l:template_map, &ft, '')

  if empty(l:template_string)
    call s:PrintError('Filetype "'.&ft.'" not suppported.')
    return
  endif

  try
    let l:full_marker = l:log_metadata . ' ' . s:log_marker . ' ' . a:variable_name
    execute "normal o" . printf(l:template_string, l:full_marker, a:variable_name)
  catch /.*/
    call s:PrintError('Invalid template: "'.l:template_string.'"')
  endtry
endfunction

au FileType * let b:comment_string = escape(substitute(&commentstring, '%s', '', ''), '/')

let s:all_debug_logs = s:log_prefix . '.*' . s:log_marker

autocmd User MapActions call MapAction('DebugLog', get(g:, 'debug_logger_keymapping', '<leader>l'))

command! CommentAllDebugLogs    :silent! call s:ExecuteKeepingCursorPosition('%s/^\(.*' . s:all_debug_logs . '.*\)/' . b:comment_string . ' \1/g')
command! DeleteAllDebugLogs     :silent! call s:ExecuteKeepingCursorPosition('g/' . s:all_debug_logs . '/d')
command! UncommentAllDebugLogs  :silent! call s:ExecuteKeepingCursorPosition('%s/^' . b:comment_string . ' //g')
