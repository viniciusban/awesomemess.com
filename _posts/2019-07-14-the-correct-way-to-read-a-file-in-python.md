---
layout: post
title: The correct way to read a file in Python
summary: There are lots of examples teaching you how to read a file in Python. What are they missing?
slug: read-file-in-python
featured-img: blur-children-class-448877
categories: [english]
---

There are a plethora of examples out there teaching you some wrong way to read a file in Python. Be warned.

Most of them don't close the file when an error occurs and several don't close the file at all.

Often they rely on Python to close the file when the program ends (what certainly happens), but if you get used to copy those examples, you will feed the bad habit to open files in an insecure way.

So, the correct way to read any file in Python is:

```
with open("input.txt") as f:
    for line in f:
        # handle "line"
        # ...

# here the file is already closed.
```

This is the correct and canonical way to read a file in Python because it's guaranteed to be closed, even in case of errors. If still in doubt, you can check [the source](https://docs.python.org/3/library/io.html#io.IOBase).

Explaining here, `with` statement is a _context processor_. `open()` returns a _[Context Manager](https://docs.python.org/3/reference/datamodel.html#context-managers)_ who always closes the file, even if you get out of it using a `break` or raising an exception.
