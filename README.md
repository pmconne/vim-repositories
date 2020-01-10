# vim-repositories

Organizes tag-based editing workflows around a set of related directories.

# Setup

This plugin uses the `VimRepos` file described in [TODO](link). It maintains a list of repositories as specified in `$(SrcRoot)VimRepos` such that:
   * Each repository has both a user-friendly name and an integer ID
   * Each repository has a tags file at its root describing the symbols in that repository
   * At any given time, there is either one 'active' repository, or all repositories are active
   * Tag search operates upon the active repository (or upon all repositories, if so specified)
   * The user can easily cycle through active repositories via the 'next/previous repository' commands
   * A list of all repositories and their corresponding IDs can be displayed at any time
   * The user can specify the active repository by ID
   * By default the active repository always corresponds to the repository containing the active buffer

# Usage

Use the "directory-based tag generation" instructions on [TODO](link) to generate tags files based on your VimRepos file.
Optionally set up mappings in your .vimrc to make the plugin feature more easily accessible.

## Sample mappings

Mappings like the following can be added to your .vimrc to make these features easily accessible:
```vi
command! -nargs=1 Repo call SetRepository(<f-args>)
cnoreabbrev repo repo<c-\>esubstitute(getcmdline(), '^repo\>', 'Repo', '')<enter>

command! -nargs=0 RepoList call ListRepositories()
cnoreabbrev repolist repolist<c-\>esubstitute(getcmdline(), '^repolist\>', 'RepoList', '')<enter>

" move to next/prev repository
nnoremap - :call IncDecRepository (1)<cr>
nnoremap _ :call IncDecRepository (0)<cr>

" Include all repositories in tags - on or off
command! -nargs=0 Ra call SetIncludeAllRepositories(1)
cnoreabbrev ra ra<c-\>esubstitute(getcmdline(), '^ra', 'Ra', '')<enter>

" Include only current repository in tags
command! -nargs=0 Rr call SetIncludeAllRepositories(0)
cnoreabbrev rr rr<c-\>esubstitute(getcmdline(), '^rr', 'Rr', '')<enter>
```

In this example, the `-` and `_` keys cycle through previous/next active repository; `:Ra` causes tag search to search all repositories; `:Repolist` lists all repositories; etc.

## vim-airline integration

I find it useful to display the name of the active repository in the airline status bar. The following line in my .vimrc enables this:
```vi
let g:airline_section_b = '%{GetCurrentRepositoryLabel()}'
```
