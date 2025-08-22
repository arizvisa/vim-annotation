# annotation.vim

This plugin leverages the text properties feature in Vim to allow a user to add
annotations to the source code they are viewing. The source code being annotated
is not tampered with to avoid affecting any kind of source code indexing that
might be used by the user. The annotations are stored out-of-band of the file
being annotated using JSON which can be processed externally or added to a
repository.

## Installation

This plugin requires Vim to be compiled with support for text properties which
can be checked by looking for the `+textprop` feature in the output of
`:version`. This plugin has been tested with Vim 9.1.

The plugin is currently hosted on GitHub at
[https://github.com/arizvisa/vim-annotation](https://github.com/arizvisa/vim-annotation).
Please use GitHub for reporting any issues or feature requests.

### Installation - Plugin manager

To install using a plugin manager, add the line corresponding to your
package manager to your `.vimrc`.

    " Vundle
    call vundle#begin()
    Plugin 'arizvisa/vim-annotation'
    ...

    " Dein
    call dein#begin(...)
    call dein#add('arizvisa/vim-annotation')
    ...

    " Neobundle
    call neobundle#begin(...)
    NeoBundleFetch 'arizvisa/vim-annotation'

### Installation - Packages

To install directly into your Vim configuration, clone the repository into your
file system at the correct `runtimepath` so that Vim's `:packadd` (from
`Packages`) will find it.

    # if in a posix environment
    $ git clone https://github.com/arizvisa/vim-annotation ~/.vim/pack/some-name/opt/vim-annotation

    # if in a windows-y environment
    $ git clone https://github.com/arizvisa/vim-annotation $USERPROFILE/vimfiles/pack/some-name/opt/vim-annotation

Afterwards, you can then use `:packadd` from `Packages` in your `.vimrc`
to add it.

    packadd 'vim-annotation'

You might also need to run `:helptags` to generate the tags for the
documentation. Please review the help for more details.

### Installation - Directly

Simply copy the root of this repository into your Vim runtime directory.
If in a posix-y environment, this is at "`$HOME/.vim`". If in windows, this
is at "`$USERPROFILE/vimfiles`".

    # Local user installation
    $ cp -R */ ~/.vim

    # Global installation
    $ cp -R */ $VIMINSTALLDIR/vimfiles

To see your runtime path, you can simply execute the following at vim's
command line.

    :set runtimepath

## About

This plugin was developed with the intention of using Vim to assist with the
auditing of source code. Due to how source code indexing tools and navigation
within them works, modifying the source code of a project to add comments can
interfere with the line numbers resulting in the source code indexing database
becoming stale. Thus, this plugin attempts to allow arbitrary annotations and
navigation between them whilst still leaving the original source code untouched.
This way annotations can be added to a repository and remain completely separate
from the target codebase.

### Credits

* Thanks to all the people who've supported the `+textprop` feature in Vim.
* Thanks to Shigio YAMAGUCHI for maintaining the GNU Global project at
  [https://www.gnu.org/software/global](https://www.gnu.org/software/global) of
  which allowed me to keep using Vim for source code audits.
* Thanks to Bram Moolenar, who passed away on August 3rd. Without him, the Vim
  project (and this plugin) would have never existed.
