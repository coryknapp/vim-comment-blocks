"if exists('g:comment_blocks') || v:version < 700|| &cp
"  finish
":endif
let g:comment_blocks = 1

let s:c_syn = "//"
let s:tab_width = 4
let s:c_lineLimit = 80
noremap <silent> <Plug>(commentsblock-gslash) :<C-u>call AlignWithLastComment()<CR>a
nmap g/ <Plug>(commentsblock-gslash)

echo "loading"

augroup checkForInCommentBlockAndPastBoundryGroup
	autocmd!
	autocmd CursorMoved <buffer> call CursorMoved()
	autocmd CursorMovedI <buffer> call CursorMoved()
augroup END

function! CursorMoved()
	echo "CursorMoved ".reltimestr(reltime())
	if( AreWeInACommentBlock() )
		echo "In a comment block"	
		" test to see if we're past our line limit.
		if( len( getline('.') ) > s:c_lineLimit )
			call MoveWordIntoNextRowCommentBlock( line('.') )
		" If we are, we'll need to move the word down
			"If the next row has an aligned comment block...
				"we're going to need to move the last word from this line onto
				"the next, and then check that line for overflow. Then repeat
				"on this line, recursively
		"else "else (If the next row is not an aligned comment block)...
				"just go ahead and append the line to a NEW comment block on the
				"next row.
		endif
	"elseif
		"test to see if we moved an existing commented block out of range.
	endif
endfunction

function! MoveWordIntoNextRowCommentBlock( rowNumber )
	"get last word of the row and remove it from the current row
	let this_line = getline( a:rowNumber )
	let this_line_split = split( this_line )
	let trans_word = this_line_split[-1]
	let this_line_update = this_line[0:-len(trans_word)]
	if( IsTheCommentBlockContinueInTheNextRow( a:rowNumber ) )
		echo trans_word
		" we need to take the trans word and put it between the comment start,
		" and the first word of the next line.
		" find position
		let next_line = getline( a:rowNumber+1 )
		" split the line over the "//"
	  	let next_line_split	= split( next_line, s:c_syn )
		call setline( a:rowNumber + 1,
					\next_line_split[0].s:c_syn." ".trans_word.next_line_split[1])
		" remove the transword from the current line
		let this_line = this_line[0:len(this_line) - len(trans_word) - 1]
		call setline( a:rowNumber, this_line )
		" adjust the cursor position, if we're at the end of our row
		echo col('.').'/'.len( this_line )
		if( col( '.' ) == (len( this_line ) + 1) )
			echo "did it"
			call cursor( a:rowNumber + 1, 
						\len(next_line_split[0]) +
						\len(s:c_syn) + 2 + 
						\len(trans_word) ) " add the constant two. (one for the
										   " space after the // and one to
										   " move the cursor to AFTER the
										   " transword
		endif
	else
		" call AlignWithLastComment() I'm not sure why this is here.  I'm
		" leaving it in incase something breaks.
		let next_line = getline( a:rowNumber+1 )
		let padding = WhiteSpace( match( this_line, s:c_syn ) - len(next_line) )
		call setline( a:rowNumber+1, next_line.padding."// ".trans_word )
		call setline( a:rowNumber,
					\this_line[0:len(this_line) - len(trans_word) - 1] )
		" put cursor at the end of the new line if we were at the end before
		if col( '.' ) == len( this_line ) - 1
			call cursor( a:rowNumber + 1, 999 )
		endif
	endif
endfunction

function! IsTheCommentBlockContinueInTheNextRow( rowNumber )
	let next_block_start = match( getline( a:rowNumber+1 ), s:c_syn )
	if( next_block_start == - 1 )
		return 0
	endif
	let this_block_start = match( getline( a:rowNumber ), s:c_syn )
	if( this_block_start == next_block_start )
		return 1
	endif
	return 0
endfunction


function! AreWeInACommentBlock()
	let index = match( getline('.'), s:c_syn )
	if( index == -1 )
		return 0
	endif
	if( index < col('.' ) )
		return 1
	endif
	return 0
endfunction

function! AlignWithLastComment()
echo "shit"
python << EOF
import vim

#vim is kinda bad at io messages, so let's open a log file for debugging
debug_out = open('log.text', 'w')
debug_out.write( "logfile\n========================" )

cw = vim.current.window
cb = vim.current.buffer
(row,col) = cw.cursor
last_line = cb[row-2]
this_line = cb[row-1]
c_syn = vim.eval( "s:c_syn" )
tab_width = int(vim.eval( "s:tab_width" ))

#first thing, if we're not at the end of a line, go there.
#vim.command( "call cursor( ["+str(row)+","+str(len(this_line))+"] )" )
#append a space

comment_col = last_line.find( c_syn )
if comment_col == -1: #no comment above.
	# Add // to the end and we're done.
	if this_line.find( c_syn ) == -1: #unless we're already in a comment
		this_line = this_line + " " + c_syn
elif comment_col < len( this_line ):
	#the comment block above is to the left of the termination of the last line
	#i.e   some code; // come comment
	#      some longer block of code;
	# so what we have to do is move the above comment over to align with this
	# one.
	this_line = this_line + " " + c_syn
	print( "later!" )
else:
	#add spaces until we align this block with the last
	tab_count = this_line.count( '\t' )
	#we have to compensate for the poor misguided people who use tabs instead of
	#space.
	padding = comment_col - len( this_line ) - ( tab_count * ( tab_width - 1 ) )
	this_line += ' '*padding
	this_line += c_syn

vim.command( "call setline(" + str(row) +",\""+this_line+"\")" )#make sure we escape any "'s

#move cursor to end of line
vim.command( "call cursor( [ line('.') ,"+str(len(this_line))+"] )" )
#vim.command( "execute \"normal! a\"" ) #go back to insert mode.
debug_out.close()
EOF
endfunction

function! WhiteSpace( length )
	let i = 0
	let whitespace = ""
	while i < a:length 
		let whitespace = whitespace." "
		let i += 1
	endwhile
	return whitespace
endfunction

