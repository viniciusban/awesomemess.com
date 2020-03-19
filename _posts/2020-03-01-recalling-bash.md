---
layout: post
title: Recalling bash
summary: This is a collection of commands, explanations, and bash tools
featured-img: don-t-forget-1434063
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
# Makefile
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
