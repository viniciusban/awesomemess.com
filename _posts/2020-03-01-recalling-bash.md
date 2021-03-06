---
layout: post
title: Recalling bash
summary: This is a collection of commands, explanations, and bash tools
featured-img: bin-bash
categories: [english]
---

I think it is worth registering some useful `bash` commands I usually forget the syntax.


## find

Remove all files with same extension:

```
$ find . -name '*.pyc' -exec rm {} \;
```

Ignore a directory in `find`. A.k.a how to exclude a directory from `find`. A.k.a how to avoid `find` searching in a directory:

```
$ find . -path ./.virtualenv -prune -o -name '*.pyc' -exec echo {} \;
```

The trick is done by the `-path ./.virtualenv -prune -o` part. You may add as many of this as you want to ignore several directories.


Include a directory in `find`. A.k.a how to search only in this directory:

```
$ find ./.virtualenv -name '*.pyc'
```

How to remove all directories with a name:

```
$ find . -name '__pycache__' -prune -execdir rm -rf {} \;
```


## make

For reference:

- [GNU Make](https://www.cl.cam.ac.uk/teaching/0910/UnixTools/make.pdf) - book in PDF written by Richard M. Stallman, Roland McGrath, and Paul D. Smith;
- [Makefile Tutorial](https://makefiletutorial.com), based on the above book.

A self documenting `Makefile`:

```
SHELL := /bin/bash

.PHONY : help
help : Makefile
	@#help: Show this screen.
	@grep -ve '^\w\+ :=' $< | \
		grep -o -e '^[^_\.]\w\+ \?:' -e '^	@#help: .\+' | \
		sed -e 's/^	@#help: /\t/' -e 's/ :/:/'


.PHONY : target
target : prerequisite
	@#help: Help text for this target
	echo 'this target'
```

This `Makefile` is a good starting point because:

1. It uses `/bin/bash` as the interpreter, instead of the default `/bin/sh`;

2. It shows a help message for each target. This trick is done by the convention used at the `@#help: ` part. This is by no means a reserved command. It is only a convetion I created. Targets starting with an underline are not listed, as they are considered "internal" only.


### make Runs Everything Separately

All commands in a `Makefile` are executed in its own subshell. So, if you need to set and environment to run a command, you should concatenate all commands in a sigle line, like this:

```
target :
	cd /project/root/directory && \
		source ./.virtualenv/bin/activate && \
		python my_program.py
```


### Variable interpolation in the Makefile

Passing variables to the invoked commmand:

```
target1 :
	echo "${MYVAR}"

target2 :
	echo "$${MYVAR}"
```

In `target1` the value of `$MYVAR` is interpolated by `make`.

In `target2` the value of `$MYVAR` is interpolated by the shell when running the `echo` command. Notice the double "$" ("$$").


## Variables in bash

Show default content if variable is empty:

```
$ echo ${NAME:-no content}
no content
$ NAME=John
$ echo ${NAME:-no content}
John
```

Now, the opposite: show some content if variable is not empty:

```
$ echo ${NAME:+has value}
$ NAME=John
$ echo ${NAME:+has value}
has value
```

Efficient "or" using pattern comparison:

```
if [[ "$option" =~ ^(-v|--verbose)$ ]]; then
  echo "verbose enabled"
else
  echo "silent"
fi
```


### Arrays

Creating and setting values:

```
$ declare -a colors
$ colors=(red blue)
$ colors+=(green)
$ echo ${colors[@]}
red blue green
```

Traversing array:

```
for item in "${colors[@]}"; do
    echo $item
done
```


## Shell Invocation ##

Start a sub-shell, execute some commands after `.bashrc` and keep the shell opened:

```
$ bash --init-file <(echo '. ~/.bashrc;pwd;ls -a')
```


## Does the file exist? ##

Reference: <https://tldp.org/LDP/abs/html/fto.html>


| File test operator | Explanation |
|--------------------|-------------|
| -a                 | Do not use it. Use -e instead. Read note below. |
| -e                 | **Any** file. _Regular_ file, directory, device, socket, pipe, symlink... |
| -f                 | _Regular_ file (not a directory or device file) exist. |
| -d                 | Directory. |
| -h, -L             | Symbolic link. |
| -S                 | Socket. |
| -r                 | **Any** file is readable by the user. |
| -w                 | **Any** file is writeable by the user. |
| -x                 | **Any** file is executable by the user. |
| -O                 | User is the owner. |

Test a file with `-a` is deprecated. It is not present in `$ man test` anymore. POSIX define `-a` as the "logical AND", as you can see it in examples below.

Examples checking for symlinks:

```
[ -L "$filename" -a -f "$filename" ] && echo 'link to a regular file'
[ -L "$filename" -a -d "$filename" ] && echo 'link to a directory'
[ -L "$filename" -a -e "$filename" ] && echo 'link to any file'
[ -L "$filename" -a ! -e "$filename" ] && echo 'broken link'
```

## Unique and/or random numbers and strings

The simplest option is to generate random numbers with a bash variable:


```
$ echo $RANDOM
```

UUIDs can be generated with:

```
$ uuidgen
```

True random strings come from `/dev/urandom` as we can see in examples below.

3-char length string with only letters and digits:

```
$ base64 /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 3
```

5 different 20-char strings with letters, digits, and some special characters:

```
$ cat /dev/urandom | tr -dc 'a-zA-Z0-9_@*' | fold -w 20 | head -n 5
```
