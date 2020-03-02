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


A self documenting `Makefile`:

```
# For reference: https://makefiletutorial.com

SHELL := /bin/bash

.PHONY : help target

help : Makefile
	@#help: Show this screen.
	@grep -o -e '^\[^_]w\+ \?:' -e '^	@#help: .\+' $< | sed -e 's/^	@#help: /\t/' -e 's/ :/:/'

target : prerequisite
	@#help: Help text for this target
	echo 'this target'
```

This `Makefile` is a good starting point because:

1. It uses `/bin/bash` as the interpreter, instead of the default `/bin/sh`;

2. It shows a description for each target. This trick is done by the convention used at the `@#help: ` part. This is by no means a reserved command. It is only a convetion I decided to use. As an alternative, targets starting with an underline are not listed, as they are considered "internal" only.


### Separated subshells.

All commands in a `Makefile` are executed in its own subshell. To avoid this, concatenate commands:

```
# Makefile
target :
	cd /some/directory; \
		activate_the_virtualenv; \
		python my_program.py
```


## Variables

Show default content if variable is empty:

```
$ echo ${NAME:-no content}
no content
$ NAME=John
$ echo ${NAME:-no content}
John
```
