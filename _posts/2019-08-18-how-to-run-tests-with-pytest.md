---
layout: post
title: How to run tests with pytest
summary: This is a self reminder about pytest invocation
featured-img: don-t-forget-1434063
categories: [english]
---

I always forget how to run `pytest` for a specific target. So, here it goes.

Pytest accepts two types of target: path (file/directory) and package/module.

The command to run varies according to the choice:

| For paths | For packages or modules |
|-----------|-------------------------|
| `$ pytest <target>` | `$ pytest --pyargs <target>` |


The `<target>` argument varies too:

| For paths | For packages or modules |
|-----------|-------------------------|
| `some/test_directory` | `some.test_package` |
| `path/to/test_file.py` | `some.package.test_module` |
| `path/to/test_file.py::test_function` | `some.package.test_module::test_function` |
| `path/to/test_file.py::TestCase`     | `some.package.test_module::TestCase` |
| `path/to/test_file.py::TestCase::test_method` | `some.package.test_module::TestCase::test_method` |

