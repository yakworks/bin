# Bash Tips

## Bash Conditional Expressions

### If Then brackets

double [[ allow you to use `&&` and `||` instead of `-a` and `-o`

### Check if File Exists

When checking if a file exists, the most commonly used FILE operators are -e and -f. The first one will check whether a file exists regardless of the type, while the second one will return true only if the FILE is a regular file (not a directory or a device).

The most readable option when checking whether a file exists or not is to use the test command in combination with the if statement . Any of the snippets below will check whether the /etc/resolv.conf file exists:

```bash
FILE=/etc/resolv.conf
if test -f "$FILE"; then
    echo "$FILE exists."
fi

if [ -f "$FILE" ]; then
    echo "$FILE exists."
fi

if [[ -f "$FILE" ]]; then
    echo "$FILE exists."
fi

test -f "$FILE" && echo "$FILE exists."

[ -f "$FILE" ] && echo "$FILE exists."

[[ -f "$FILE" ]] && echo "$FILE exists."

if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist."
fi

```

If you want to run a series of command after the && operator simply enclose the commands in curly brackets separated by ; or &&:

```bash
FILE=/etc/resolv.conf
[ -f "$FILE" ] && { echo "$FILE exist."; cp "$FILE" /tmp/; }
[ -f "$FILE" ] && echo "$FILE exist." || echo "$FILE does not exist."
```

### Check if File does Not Exist

```bash
FILE=/etc/resolv.conf
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
fi

[ ! -f "$FILE" ] && echo "$FILE does not exist."
```

### Check if Multiple Files Exist
```bash
if [ -f /etc/resolv.conf -a -f /etc/hosts ]; then
    echo "Both files exist."
fi


# double brackets when using &&
if [[ -f /etc/resolv.conf && -f /etc/hosts ]]; then
    echo "Both files exist."
fi

[ -f /etc/resolv.conf -a -f /etc/hosts ] && echo "Both files exist."

# double brackets when using &&
[[ -f /etc/resolv.conf && -f /etc/hosts ]] && echo "Both files exist."
```

### Operators

The test command includes the following FILE operators that allow you to test for particular types of files:

#### File

* `-d FILE` - True if the FILE exists and is a directory.
* `-e FILE` - True if the FILE exists and is a file, regardless of type (node, directory, socket, etc.).
* `-f FILE` - True if the FILE exists and is a regular file (not a directory or device).
* `-h FILE` - True if the FILE exists and is a symbolic link.
* `-L FILE` - True if the FILE exists and is a symbolic link.
* `-O FILE` - True if the FILE exists and is owned by the user running the command.
* `-s FILE` - True if the FILE exists and has nonzero size.
* `-w FILE`- True if the FILE exists and is writable.
* `-x FILE` - True if the FILE exists and is executable.

#### Other

* `-n VAR` - True if the length of VAR is greater than zero.
* `-z VAR` - True if the VAR is empty.
* `STRING1 = STRING2` - True if STRING1 and STRING2 are equal.
* `STRING1 != STRING2` - True if STRING1 and STRING2 are not equal.
* `INTEGER1 -eq INTEGER2` - True if INTEGER1 and INTEGER2 are equal.
* `INTEGER1 -gt INTEGER2` - True if INTEGER1 is greater than INTEGER2.
* `INTEGER1 -lt INTEGER2` - True if INTEGER1 is less than INTEGER2.
* `INTEGER1 -ge INTEGER2` - True if INTEGER1 is equal or greater than INTEGER2.
* `INTEGER1 -le INTEGER2` - True if INTEGER1 is equal or less than INTEGER2.

## Bash For Loop

```bash
for item in [LIST]; do
  [COMMANDS]
done

for element in Hydrogen Helium Lithium Beryllium;do
  echo "Element: $element"
done
```

### Range

```bash
for i in {0..3}
do
  echo "Number: $i"
done

# {START..END..INCREMENT}
for i in {0..20..5}
do
  echo "Number: $i"
done
```

### Loop over array elements

```bash
BOOKS=('Atlas Shrugged' 'Don Quixote' 'Ulysses' 'The Great Gatsby')

for book in "${BOOKS[@]}"; do
  echo "Book: $book"
done
```

### C-style Bash for loop

```bash
for ((i = 0 ; i <= 1000 ; i++)); do
  echo "Counter: $i"
done
```

### break and continue Statements 

```bash
for element in Hydrogen Helium Lithium Beryllium; do
  if [[ "$element" == 'Lithium' ]]; then
    break # this could be on single line with &&
  fi
  echo "Element: $element"
done

for i in {1..5}; do
  # ifs can be on single line as outined in inf then section
  [[ "$i" == '2' ]] && continue
  echo "Number: $i"
done

```

### Real World

#### Renaming files with spaces in the filename

```bash

for file in *\ *; do
  mv "$file" "${file// /_}"
done
```

- The first line creates a for loop and iterates through a list of all files with a space in its name. The expression `*\ *` creates the list.
- The second line applies to each item of the list and moves the file to a new one replacing the space with an underscore `_`. The part `${file// /_}` is using the shell parameter expansion to replace a pattern within a parameter with a string.
- done indicates the end of the loop segment.

