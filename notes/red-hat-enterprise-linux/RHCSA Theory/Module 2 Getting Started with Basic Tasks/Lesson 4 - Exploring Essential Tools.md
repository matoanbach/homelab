## 4.1 Using `man`
- man is the best source to get extensive usage information
    - Sections define command types
    - Many man pages have examples
    - Search for text using `/` 
- Other documentation solutions are available, but not as important
    - GNU software has fiull documentation available through `info`
    - `pinfo` is an easier interface to navigate than `info`

### `man` Sections
- Documentation in man is organized in different sections
- For basic administration, the following sections matter most
    - 1 - Executable programs or shell commands
    - 5 - File formats and conventions
    - 8 - System administration commands
- All sections are described in `man man` 
- Use `man n intro` for an introduction to the topic of a specific section number

## 4.2 Finding the Right man Page
- All `man` pages are indexed in the mandb
- Use `man -k` or `apropos` to search the mandb based on a keyword
- A lot of results can show, use `grep` to filter the results
- The mandb is built automatically through a scheduled task
- Manually trigger a rebuild using `sudo mandb`

## 4.3 Using an Editor
### `nano`
- `nano` is the easy-to-use editor
- After starting it, you can start editing text immediately

### `vim`
- `/text` - Search for "text"
- `?text` - Search backwards for "text"
- `^` - move to start of line
- `$` - move to end of line
- `w` - move to the next word
- `:%s/old/new/g` - Substitute all occurences of "old" with "new"