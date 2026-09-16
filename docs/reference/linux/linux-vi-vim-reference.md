# vi / Vim Quick Reference

## Overview

`vi` and Vim are terminal-based text editors commonly available on Linux and Unix systems.

They are particularly useful for:

- Editing configuration files
- Working on remote systems over SSH
- Editing files from a server console
- Making quick changes without a graphical environment
- Working in minimal or recovery environments

Vim extends the original `vi` editor with additional features while retaining the same core commands.

## Editor Modes

Understanding modes is the key to using `vi` efficiently.

| Mode | Purpose | Enter With |
|---|---|---|
| Normal | Navigation and commands | `Esc` |
| Insert | Enter and edit text | `i`, `a`, `o`, etc. |
| Visual | Select text | `v`, `V`, `Ctrl+v` |
| Command-line | Save, quit, search/replace, settings | `:` |

When unsure which mode is active:

```text
Esc
```

Pressing `Esc` returns to Normal mode.

## Opening Files

Open a file:

```bash
vi filename
```

Open a system configuration file:

```bash
sudo vi /path/to/config
```

Open directly at a specific line:

```bash
vi +50 filename
```

Open at the first occurrence of a word:

```bash
vi +/searchterm filename
```

## Entering Insert Mode

From Normal mode:

| Command | Action |
|---|---|
| `i` | Insert before cursor |
| `I` | Insert at beginning of line |
| `a` | Append after cursor |
| `A` | Append at end of line |
| `o` | Create new line below |
| `O` | Create new line above |

A particularly useful workflow for configuration files is:

```text
o
```

This creates a new line underneath the current line and immediately enters Insert mode.

Return to Normal mode with:

```text
Esc
```

## Saving and Exiting

Enter these commands from Normal mode.

| Command | Action |
|---|---|
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:x` | Save if changed and quit |
| `:q!` | Quit without saving |
| `:w!` | Force save when permitted |
| `ZZ` | Save and quit |
| `ZQ` | Quit without saving |

Common workflow:

```text
Esc
:wq
Enter
```

## Basic Navigation

Normal mode provides fast navigation without arrow keys.

| Command | Movement |
|---|---|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |
| `w` | Forward one word |
| `b` | Back one word |
| `e` | End of word |
| `0` | Beginning of line |
| `^` | First non-whitespace character |
| `$` | End of line |
| `gg` | Beginning of file |
| `G` | End of file |

Arrow keys also normally work, but learning `hjkl` avoids moving your hands away from the main keyboard area.

## Jumping Around Quickly

These commands are especially useful when editing long configuration files.

| Command | Action |
|---|---|
| `gg` | First line |
| `G` | Last line |
| `50G` | Jump to line 50 |
| `:50` | Jump to line 50 |
| `Ctrl+f` | Page forward |
| `Ctrl+b` | Page backward |
| `Ctrl+d` | Half-page down |
| `Ctrl+u` | Half-page up |
| `H` | Top of visible screen |
| `M` | Middle of visible screen |
| `L` | Bottom of visible screen |

Example:

```text
125G
```

jumps directly to line 125.

## Editing Text

From Normal mode:

| Command | Action |
|---|---|
| `x` | Delete character |
| `X` | Delete previous character |
| `dd` | Delete current line |
| `D` | Delete from cursor to end of line |
| `dw` | Delete word |
| `d$` | Delete to end of line |
| `cc` | Replace entire line |
| `cw` | Replace word |
| `C` | Replace from cursor to end of line |
| `r` | Replace one character |
| `J` | Join current line with next line |

Commands can be combined with counts.

Delete five lines:

```text
5dd
```

Delete three words:

```text
3dw
```

## Copy and Paste

In `vi`, copying is called **yanking**.

| Command | Action |
|---|---|
| `yy` | Copy current line |
| `Y` | Copy current line |
| `yw` | Copy word |
| `y$` | Copy to end of line |
| `p` | Paste after/below cursor |
| `P` | Paste before/above cursor |
| `dd` | Delete line and place it in buffer |

Copy a line and paste it underneath:

```text
yy
p
```

Copy five lines:

```text
5yy
```

Then move somewhere else and:

```text
p
```

This is particularly useful for duplicating configuration blocks.

## Undo and Redo

| Command | Action |
|---|---|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `U` | Undo changes to current line in traditional vi behavior |

Example:

```text
u
```

can immediately recover from an accidental deletion.

## Searching

Search forward:

```text
/searchterm
```

Search backward:

```text
?searchterm
```

After searching:

| Command | Action |
|---|---|
| `n` | Next match |
| `N` | Previous match |
| `*` | Search forward for word under cursor |
| `#` | Search backward for word under cursor |

For example, place the cursor over:

```text
gateway
```

and press:

```text
*
```

to immediately find the next occurrence.

## Search and Replace

Replace the first occurrence on the current line:

```text
:s/old/new/
```

Replace every occurrence on the current line:

```text
:s/old/new/g
```

Replace throughout the entire file:

```text
:%s/old/new/g
```

Ask for confirmation before every replacement:

```text
:%s/old/new/gc
```

Example:

```text
:%s/server01/server02/gc
```

This is useful when modifying hostnames, interface names, configuration values, or repeated parameters.

## Visual Selection

Vim provides several selection modes.

| Command | Action |
|---|---|
| `v` | Character selection |
| `V` | Line selection |
| `Ctrl+v` | Block/column selection |

After selecting text:

| Command | Action |
|---|---|
| `y` | Copy |
| `d` | Delete |
| `c` | Replace |
| `>` | Indent |
| `<` | Unindent |

Example workflow:

```text
V
j
j
y
```

Selects three lines and copies them.

Then:

```text
p
```

pastes the copied block.

## Line Numbers

Enable line numbers:

```text
:set number
```

Disable them:

```text
:set nonumber
```

Short forms:

```text
:set nu
:set nonu
```

Relative line numbers in Vim:

```text
:set relativenumber
```

Both absolute and relative numbering can be useful:

```text
:set number relativenumber
```

## Useful Navigation Tricks

### Match Brackets

Place the cursor on a bracket, brace, or parenthesis and press:

```text
%
```

Vim jumps to its matching pair.

Useful with:

```text
()
[]
{}
```

### Jump to a Character

Move forward to the next `=`:

```text
f=
```

Move backward to the previous `=`:

```text
F=
```

Move just before the next `=`:

```text
t=
```

Repeat the previous character search:

```text
;
```

Reverse it:

```text
,
```

These commands are especially useful when editing structured configuration lines.

## Command Repetition

The `.` command repeats the previous edit.

For example:

1. Change one configuration value.
2. Move to another similar line.
3. Press:

```text
.
```

Vim repeats the same edit.

This is one of the most useful Vim commands for repetitive configuration work.

## Indentation

| Command | Action |
|---|---|
| `>>` | Indent line |
| `<<` | Unindent line |
| `5>>` | Indent five lines |
| `=` | Auto-indent selected text |
| `gg=G` | Auto-indent entire file |

## Working With Multiple Files

Open another file:

```text
:e filename
```

Reload the current file:

```text
:e
```

Force reload and discard unsaved changes:

```text
:e!
```

See open buffers:

```text
:ls
```

Move to next buffer:

```text
:bn
```

Move to previous buffer:

```text
:bp
```

## Running Shell Commands

Run a shell command without leaving Vim:

```text
:!command
```

Example:

```text
:!ip addr
```

or:

```text
:!systemctl status ssh
```

Return to the editor after the command completes.

## Quick Sysadmin Workflow

A common server administration workflow is:

```bash
sudo vi /path/to/config
```

Inside Vim, search for the setting:

```text
/searchterm
```

Navigate to the desired configuration and press:

```text
i
```

or:

```text
A
```

Make the change, then:

```text
Esc
:wq
```

Validate the service configuration before restarting or reloading it whenever the application provides a validation command.

## High-Value Commands to Memorize

| Command | Purpose |
|---|---|
| `i` | Start inserting |
| `Esc` | Return to Normal mode |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `/text` | Search |
| `n` | Next search result |
| `*` | Search for word under cursor |
| `0` | Beginning of line |
| `$` | End of line |
| `w` | Next word |
| `gg` | Beginning of file |
| `G` | End of file |
| `50G` | Jump to line 50 |
| `.` | Repeat previous edit |
| `%` | Jump to matching bracket |
| `5dd` | Delete five lines |
| `:%s/old/new/gc` | Replace throughout file with confirmation |

## Command Pattern

Many Vim commands follow a reusable structure:

```text
[count][command][movement]
```

For example:

```text
d$
```

means:

```text
delete + to end of line
```

while:

```text
dw
```

means:

```text
delete + word
```

and:

```text
3dd
```

means:

```text
3 + delete line
```

Learning this pattern is more useful than memorizing every possible command individually.

## Practical Examples

Delete the current line:

```text
dd
```

Copy a configuration line and duplicate it:

```text
yyp
```

Move to the end of a line and append:

```text
A
```

Find the next occurrence of `DNS`:

```text
/DNS
```

Jump directly to line 75:

```text
75G
```

Replace all occurrences of an old hostname:

```text
:%s/old-host/new-host/gc
```

Undo a mistake:

```text
u
```

Repeat the last edit:

```text
.
```

Save and exit:

```text
:wq
```

Discard all changes:

```text
:q!
```

## vi vs Vim

`vi` refers to the traditional Unix visual editor and command model.

Vim means **Vi IMproved** and adds features such as:

- Syntax highlighting
- Additional undo functionality
- Visual selection
- Improved search
- Plugins
- Split windows
- Additional configuration options

On many Linux distributions, invoking:

```bash
vi
```

may actually launch Vim or another vi-compatible implementation.

For routine infrastructure administration, the core `vi` command set remains portable and is the most important part to learn.

Many modern Linux distributions provide a vi-compatible editor through the vi command. 
Depending on the distribution and installed packages, vi may launch Vim or another vi-compatible implementation. 
Commands documented as Vim-specific may not be available in every vi implementation.
