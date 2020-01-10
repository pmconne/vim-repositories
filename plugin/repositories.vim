" Maintains a list of known repositories.
" Each repository has a corresponding number.
" Each repository has a tags file at its root.
" The current repository is determined by the current working directory, which
" is often determined by the current buffer.
" Vim's tag functions will operate on the tags defined for the current
" repository.
" 
" ListRepositories() - list repository names and numbers
"
" SetRepository(ID) - change working directory to repository root
"
" FindTagInRepository(name, tag) - search specified repository for the tag
"
" FindTagInRepositoryByNumber(ID, tag) - search specified repository for the tag
"
" FindTagInAllRepositories(tag) - search all repositories for the tag
"
" FindTag* functions perform a 'tagjump', listing all matches if more than one
" exists.

" %SrcRoot%VimRepos should be a text file of the following format:
"   RepoName1 PathRelativeToSrcRoot
"   RepoName2 PathRelativeToSrcRoot
"   ...
" 

" repository names mapped to path relative to $SrcRoot
let s:repos = { }
" in search order.
let s:orderedRepos = [ ]

" read repo list from config
let repofile = $SrcRoot . "\\VimRepos"
if (filereadable(repofile))
    let lines = readfile ($SrcRoot . "\\VimRepos")
    for line in lines
        let parts = split(line)
        if (2 == len (parts))
            let s:repos[parts[0]] = parts[1]
            call add (s:orderedRepos, parts[0])
        endif
    endfor
endif

" Return the name of the highest-priority repository
function! GetDefaultRepository()
    return s:orderedRepos[0]
endfunction

" for searching all repositories
let s:tagPaths = ""
for repoName in s:orderedRepos
    let repo = s:repos[repoName]
    let s:tagPaths = s:tagPaths . $SrcRoot . repo . "\\tags,"
endfor
" let s:tagPaths = s:tagPaths . "\\tags"

function! GetRepositories()
    return s:repos
endfunction

" Get repository root path relative to $SrcRoot
function! GetRepositoryPath(name)
    return s:repos[a:name]
endfunction

function! GetRepositoryNumber(name)
    let i = 0
    for repo in s:orderedRepos
        let i += 1
        if repo ==? a:name
            return i
        endif
    endfor

    return 0
endfunction

function! GetRepositoryByNumber (num)
    let num = a:num - 1
    return num < len(s:orderedRepos) ? s:orderedRepos[num] : ""
endfunction

" list repository names and IDs
function! ListRepositories()
    let i = 0
    for repo in s:orderedRepos
        let i += 1
        echo i . " " repo
    endfor
endfunction

" determine repository based on path relative to $SrcRoot
function! GetRepositoryFromRelativePath (path)
    let pathlen = strlen (a:path)
    if 0 < pathlen
        let path = tolower(a:path)
        for repo in items(s:repos)
            let idx = stridx (path, repo[1])
            if 0 == idx
                let repolen = strlen (repo[1])
                if pathlen == repolen || strpart(path, repolen, 1) == '\'
                    return repo[0]
                endif
            endif
        endfor
    endif

    return "(No Repository)"
endfunction

" determine current repository based on current working directory
function! GetCurrentRepository()
    let cwd = tolower (getcwd())
    let path = ""
    if 0 == stridx (cwd, tolower($SrcRoot))
        let path = strpart (cwd, strlen ($SrcRoot))
    endif

    return GetRepositoryFromRelativePath (path)
endfunction

" execute tagjump with tags set to specified location(s)
function! FindTagIn (where, search)
    let found = 0
    try
        let savedtags = &tags
        let &tags = a:where
        execute "tj " . a:search
        let found = 1
    finally
        let &tags = savedtags
    endtry

    return found
endfunction

function! MakeRepositoryFullPath (repo)
    return $SrcRoot . GetRepositoryPath(a:repo) . "\\"
endfunction

" set whether all repositories are searched for tags, or only current repo
let s:includeAllRepos = 0
function! SetIncludeAllRepositories (includeAll)
    if s:includeAllRepos == a:includeAll
        return
    endif

    let s:includeAllRepos = a:includeAll

    if (a:includeAll)
        let &tags = s:tagPaths
    else
        let &tags = "tags;/"
    endif
endfunction

" change current working directory to specified repository root
function! SetRepository (id)
    let repo = GetRepositoryByNumber (a:id)
    if (a:id == GetRepositoryNumber (repo))
        execute "cd " . MakeRepositoryFullPath (repo)
        call SetIncludeAllRepositories (0)
    else
        echo "Repository not found"
    endif
endfunction

" search specific repository by name for tag
function! FindTagInRepository (repo, search)
    return FindTagIn (MakeRepositoryFullPath (a:repo) . "tags", a:search)
endfunction

" search specific repository by ID for tag
function! FindTagInRepositoryByNumber (id, search)
    let repo = GetRepositoryByNumber (a:id)
    return 0 < strlen(repo) ? FindTagInRepository (repo, a:search) : 0
endfunction

" search all known repositories for tag
function! FindTagInAllRepositories (search)
    return FindTagIn (s:tagPaths, a:search)
endfunction

" next/prev repository
function! IncDecRepository (fwd)
    let curRepoId = GetRepositoryNumber (GetCurrentRepository())
    if (0 == curRepoId)
        let curRepoId = a:fwd ? 1 : len(s:orderedRepos)
    else
        let curRepoId = a:fwd ? curRepoId + 1 : curRepoId - 1
        if (0 == curRepoId)
            let curRepoId = len(s:orderedRepos)
        elseif (len(s:orderedRepos) < curRepoId)
            let curRepoId = 1
        endif
    endif

    call SetRepository (curRepoId)
endfunction

function! GetCurrentRepositoryLabel()
    if s:includeAllRepos
        return "All Repositories"
    else
        return GetCurrentRepository()
    endif
endfunction

