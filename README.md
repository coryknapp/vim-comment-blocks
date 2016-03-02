# vim-comment-blocks

A vim plugin for nicely aligned comments

## Installation

I've tested it with [Vundle](https://github.com/VundleVim/Vundle.vim) but I
don't think there is anything too weird here that any plugin manager shouldn't
be able to handle.

I assume you need vim with python.

I've tested this on Mac OS X and MacVim, others have tested it on windows and
have found it to work (Thanks @zQueal).

## Usage

* In normal mode, `g/` will add a ` //`to the end of the current line, padding
spaces as necessary to align with the comment block above.
* Comments will automatically wrap at 80 characters.

## Contributing

I'm very open to contributions, suggestions, and criticisms.  Like everyone, I'm
still learning VimScript.
