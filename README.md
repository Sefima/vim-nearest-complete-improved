# Vim Nearest Complete Improved

This plugin is a fork of [sirdavidoff/vim-nearest-complete](https://github.com/sirdavidoff/vim-nearest-complete).

Simple completion plugin based on open buffers made to replace vim's default completefunc. Nearest to cursor completion candidates are ordered at the top. It supports camel cases and snake cases. For instance,
`land` will match `England`, `land_of_joy`, `joy_of_land`, `landOfJoy`, `joyOfLand`.


# Setup
Install with your favorite vim package manager.

### Basics :
```
set completefunc=NearestComplete
set completeopt=menu
```

### Keymaps
You can either chose to trigger completion with `<C-n>`, which I prefer (1) or go the tab way.

### 1. C-N
Use `<C-n>` to trigger completion, `<Esc>` will close the completion menu, `<CR>` will accept completion candidate.
```
inoremap <silent><expr> <C-n>      pumvisible() ? "\<C-n>" : "\<C-x><C-u>"
imap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
imap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
```

### 2. Tab
For those who prefer to use `<Tab>` (credits to [Sir deathbeam](https://deathbeam.github.io/Fuzzy-completion-in-Vim)) :


```
function! TabComplete()
    let col = col('.') - 1

    if !col || getline('.')[col - 1] !~# '\k'
    call feedkeys("\<tab>", 'n')
    return
    endif

    call feedkeys("\<c-x>\<c-u>")
endfunction

inoremap <silent> <tab> <c-o>:call TabComplete()<cr>
```






