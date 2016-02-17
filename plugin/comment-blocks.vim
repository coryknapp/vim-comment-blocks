if exists('g:comment_blocks') || v:version < 700|| &cp
  finish
endif
let g:loaded_color_flash = 1

" calling  expand('<sfile>') gives the name of the enclosing function, so we
" have to do it in advance
let s:script_path = expand('<sfile>:p:h').'/flash.py'

nnoremap <silent> <Plug>(commentsblock-gslash) :<C-u>call AlignWithLastComment(expand('<cword>'))<CR>a
nmap g/ <Plug>(commentsblock-gslash)

function! AlignWithLastComment(...)
python << EOF
import vim



cw = vim.current.window
cb = vim.current.buffer
(row,col) = cw.cursor
last_line = cb[row-2]
this_line = cb[row-1]

#first thing, if we're not at the end of a line, go there.
#vim.command( "call cursor( ["+str(row)+","+str(len(this_line))+"] )" )
#append a space

#dipdipdipdipdipdipdip // //
#goooooooop            // // // // //
comment_col = last_line.find( "//" )
if comment_col == -1: #no comment above.  Add // to the end and we're done.
	this_line = this_line + " //"
elif comment_col < len( this_line ):
	#the comment block above is to the left of the termination of the last line
	#i.e   some code; // come comment
	#      some longer block of code;
	# so what we have to do is move the above comment over to align with this
	# one.
	this_line = this_line + " //"
	print( "later!" )
else:
	#add spaces until we align this block with the last
	this_line += ' '*(comment_col - len( this_line ))
	this_line += '//'

vim.command( "call setline(" + str(row) +",\""+this_line+"\")" )#make sure we escape any "'s

#move cursor to end of line
vim.command( "call cursor( [ line('.') ,"+str(len(this_line))+"] )" )
vim.command( "execute \"normal! a\"" ) #go back to insert mode.
EOF
endfunction
