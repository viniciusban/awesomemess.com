---
layout: post
title: Mocking in Python
summary: An "I want to" approach to straight use of the Python's mocking library.
featured-img: eyeglasses
categories: [english]
---

In this text about Python's built-in `unittest.mock` library, I address my personal needs in a very practical way to handle mocking in Python.  It is guided by, and based on questions that usually come to myself when I am writing tests that need to use test doubles.


## Behind the names

I believe that naming things correctly is at the core of software development. Since there is a wide variety of names about this subject, and to avoid misunderstanding, it is necessary to set up a convention.

**Code under test** is our target, i.e., the code we want to test. It normally is a method or a function.

**Collaborator code** helps the code under test, usually being called by it.

Both Code under test and Collaborator code are the **Production code**, i.e., the code that will run in production.

**Test code** is the code we write to exercise — call —, the code under test and make assertions about its behaviour or its result. For instance, to check if the `apply_discount_on_first_order()` function decreased the price as expected.

**Test double** is a "stunt double" replacing collaborator code as a way to run a test code.

All above names are self-explanatory to somebody writing tests, except the **Test double**. Being so, keep reading to understand a bit more about it and its importance to tests.

In the cinema, stunt doubles usually look like the main actors and their work is to replace those actors in some scenes. Stunt doubles exist to protect the main actors from stunts or to accomplish some performance they are not capable of. Somehow, a **test double** works alike, but it only replaces the "actor" during the test phase; never in production.

Since the roles of a test double can vary, several aliases were created to distinguish them, such as: _dummy_, _fake_, _stub_, _spy_, and _mock_. If you are unfamiliar with this classification, I suggest you read a great text by Martin Fowler, [Mocks aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html#TheDifferenceBetweenMocksAndStubs).

As we now have all pieces named accordingly and clarified, we can jump into the useful scenarios to use test doubles in Python. But first, it is important to say we will not discuss how to use `unittest.mock` and its syntax. Instead, we will focus on the situations a test double is useful in and how it can help us to simplify tests.


## I want a "do-nothing" replacement

In this example we will use a test double to replace a collaborator code with a "do-nothing" behaviour.

Suppose you want to test the function below:

```
def raise_salary(department, percentage):
    """
    Raise salary to employees working here for at least 15 years
    """"
    employees = Employees.filter_by(department=department)
    for e in employees:
        if e.start_date.year <= FIFTEEN_YEARS_AGO:
            e.salary *= (1 + percentage)
            Employees.save(e)
            report_raised(e)
```

There are several scenarios we could build to test the above function, but here we will use only one of them as an example: assert who has been hired less than 15 years ago does not have their salary raised.

To build this test scenario, we must:

1. Populate the database with one employee hired less than 15 years ago;
1. Call the code under test: the `raise_salary()` function;
1. Check the employee keeps the same salary.

Very straight, except by one detail: the code under test calls `report_raised()`, which is a collaborator function we do not want to run, because it is not important in this test.

The situation: we have to run the code under test, but `report_raised()` should not be called or, even if called, it should do nothing.

The solution: we must replace `report_raised()` at run time with a callable that does nothing. A **dummy object**.

The implementation: use `mock.patch()` as a decorator to replace `report_raised()` with a `mock.MagicMock` instance. By default, `MagicMock` instances do nothing when called. It is definitely what we need.

```
import unittest
from unittest import mock

from repository import Employees
from business_functions import raise_salary

class TestRaiseSalary(unittest.TestCase):
  @mock.patch("business_functions.report_raised", new=mock.MagicMock())
  def test_must_keep_same_salary_if_hired_less_than_15years_ago(self):
    sellers = "sellers"
    e = Employees.create(employee_factory(
      start_date=LAST_YEAR, department=sellers, salary=100.00
    ))
    raise_salary(sellers, 0.10)
    same_e = Employees.get(id=e.id)
    self.assertEqual(same_e.salary, 100.00)
```

Tip: filling the `new` argument in `mock.patch()` avoids receiving the mocked object in your test case.

And we are done. We could run the code under test without the side effect of running a non-desirable support function (`report_raised()`). We replaced it with a do-nothing callable, a **dummy object**.




Note: This is a work in progress. Everything below this point will be revisited and rewritten. Come back soon.

---



## I want to have control over the real thing

The production code I want to exercise uses a method from a class, but I want
to determine what it responds to have a constant output and idempotent tests.

This class has other methods and properties I don't care about in this test,
but I want to focus only in this specific method.

Solution: We want a Stub, i.e., a canned response to calls. Patch the specific
method, receive it in the parameters list and set its `return_value`.

```
# Patch the method, receive it as a parameter and set a return_value.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A.f")
def a(stub_f):
    stub_f.return_value = "my custom returned value"
    print ("Patched f():", A().f(), end="\n\n")

a()
print ("Back to the originals:", (A().f(), A().g()))
```

The solution above handles the patching of only one method. But if you want to
control more than one, I suggest you to patch the entire class and set a
`return_value` for each of the methods we want to control.

```
# Patch the entire class, receive it as a parameter and set a
# return_value for the desired methods.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A")
def a(patcher_A):
    stub_A = patcher_A.return_value
    stub_A.f.return_value = "my custom returned value"
    stub_A.g.return_value = "the return of the other method"
    print ("Patched f():", A().f())
    print ("Patched g():", A().g(), end="\n\n")

a()
print ("Back to the originals:", (A().f(), A().g()))
```

Back to the one-method scenario, if you have several consecutive calls to the
method you want to control, and each call should return a different value, you
should set the `side_effect` property with a list of values.

```
# Patch the method, receive it as parameter and set a side_effect to
# control consecutive calls.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A.f")
def a(stub_f):
    stub_f.side_effect = ["first call", "second call", "and so on..."]
    print ("Patched f():", A().f())
    print ("Patched f():", A().f())
    print ("Patched f():", A().f(), end="\n\n")

a()
print ("Back to the originals:", (A().f(), A().g()))
```

Yet another similar situation is when you need to force an exception. To get
there, set `side_effect` again.

```
# Patch the method, receive it as a parameter and set a side_effect
# to raise and exception.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A.f")
def a(stub_f):
    stub_f.side_effect = RuntimeError("My own forced error")
    try:
        A().f()
    except RuntimeError as exc:
        print ("Raised: %s" % exc, end="\n\n")
    else:
        print ("Not raised an exception")

a()
print ("Back to the originals:", (A().f(), A().g()))
```

## I want to inspect the real thing

I want to check how the production code called some method(s) of this class.

Solution: We want a Spy to inspect how things are done under the ground. Patch
the specific method or the entire class, receive it in the parameters list and
check how it was called.

```
# Patch the method, receive it as a parameter and inspect how it
# was called.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A.f")
def a(spy_f):
    A().f("something")
    spy_f.assert_called_with("something")

a()
print ("Back to the originals:", (A().f(), A().g()))


# Patch the entire class, receive it as a parameter and inspect
# how some method was called.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A")
def a(patcher_A):
    spy_A = patcher_A.return_value
    A().f("something")
    spy_A.f.assert_called_with("something")

a()
print ("Back to the originals:", (A().f(), A().g()))
```

I want to know if some argument was passed to the method, despite the other
arguments.

```
# Patch the entire class, receive it as a parameter and inspect
# if some specific argument was passed to a method.

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A")
def a(patcher_A):
    spy_A = patcher_A.return_value
    some_structure = {"name": "Mr. Holmes", "address": "221B Baker Street, London"}

    A().f(some_arg="something", other_arg="other thing", structure=some_structure)

    (_, kwargs) = spy_A.f.call_args
    if kwargs["structure"] is some_structure:
        print ("`some_structure` passed", end="\n\n")
    else:
        print ("`some_structure` not passed", end="\n\n")

a()
print ("Back to the originals:", (A().f(), A().g()))
```

That's it. These are the most common uses for the `unittest.mock` library.
Obviously I left out many topics about mocking in Python, but surely you can
find excelent resources about them in the internet.
