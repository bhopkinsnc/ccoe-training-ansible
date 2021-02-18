# VI Cheatsheet

## Cursor Movement

```bash
h        # move cursor left
j        # move cursor down
k        # move cursor up
l        # move cursor right
0        # jump to the start of the line
$        # jump to the end of the line
Ctrl + b # move back one full screen
Ctrl + f # move forward one full screen
```

## Insert and Appending Text 

```bash
i        # insert before the cursor
I        # insert at the beginning of the line
a        # insert (append) after the cursor
A        # insert (append) at the end of the line
esc      # exit insert mode
```

## Editing Content

```bash
r        # replace a single character
J        # join line below to the current one
cc       # change (replace) entire line
cw       # change (replace) to the start of the next word
c$       # change (replace) to the end of the line
.        # repeat last command
u        # undo
ctrl + r # redo
```

## Cut and Paste

```bash
yy or Y  # yank (copy) a line
2yy      # yank (copy) 2 lines
p        # put (paste) the clipboard after cursor
P        # put (paste) before cursor
dd       # delete (cut) a line
2dd      # delete (cut) 2 lines
dw       # delete (cut) the characters of the word from the cursor position to the start of the next word
x        # delete (cut) character
```

## Search and Replace

```bash
/pattern       # search for pattern
?pattern       # search backward for pattern
n              # repeat search in same direction
N              # repeat search in opposite direction
:%s/old/new/g  # replace all old with new throughout file
:%s/old/new/gc # replace all old with new throughout file with confirmations
```

## Exiting

```bash
:w              # write (save) the file, but don't exit
:w !sudo tee %  # write out the current file using sudo
:wq or :x or ZZ # write (save) and quit
:q              # quit (fails if there are unsaved changes)
:q! or ZQ       # quit and throw away unsaved changes
```
