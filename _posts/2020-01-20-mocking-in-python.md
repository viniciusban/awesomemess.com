---
layout: post
title: Mocking in Python
summary: An "I want to" approach to straight use of the Python's mocking library.
featured-img: eyeglasses
categories: [english]
---

In this article about Python's built-in `unittest.mock` library, I address my personal needs in a very practical way to handle mocking in Python, guided by questions I usually make when I want to write tests and use mock objects.

When we talk about mocks, we are really talking about doubles. In the cinema industry, doubles are people who risk their lives in dangerous takes to preserve the famous actor. If a double get hurt the audience won't feel anything because the star artist will continue appearing in the movie and attending interviews. So, a double is someone who preserves the "actual" artist.

In automated testing techniques we have a wide range of names to specify doubles. Martin Fowler's great article [Mocks aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html#TheDifferenceBetweenMocksAndStubs) clarifies this grey field. I suggest you read it and come back here, if you are unfamiliar with the difference between dummy, fake, stub, spy and mock.

As you now understood (or already knew about) test doubles, we can say in a nutshell, when testing you usually do:

1. Ignore some class or method used by your code under test;
2. Configure what a specific method returns;
3. Check how some method was called by the code under test.

We go through these topics, but first I will introduce the simple Python class we will use for all code examples here:

```
class A:
    def f(self):
        return "original f()"

    def g(self):
        return "original g()"
```

All implementations will use it to demonstrate how to handle mocking in Python.

It is important to state I consider you already know the basics of the `unittest.mock` library. So, I do not touch [where to patch](https://docs.python.org/3.7/library/unittest.mock.html#where-to-patch) here.

Then, let's get started.


## I want to ignore the real thing

I don't want to see the work of some real class, probably because it touches the database, or it accesses an external API, or it does something unimportant to this test case.

Also, I don't want to know anything about what the production code did with it, nor set any return value from its methods. I really just want nothing to be done when it's called.

Solution: We want a dummy implementation. Just `patch` the class and forget it.

Tip: pass the `new` argument to avoid poluting the parameters list unecessarily.

```
# As a decorator

print ("Originals:", (A().f(), A().g()), end="\n\n")

@mock.patch("__main__.A", new=mock.MagicMock())
def a():
    print ("Patched f():", A().f())
    print ("Patched g():", A().g(), end="\n\n")

a()
print ("Back to the originals:", (A().f(), A().g()))



# As a context processor

print ("Originals:", (A().f(), A().g()), end="\n\n")

with mock.patch("__main__.A"):
    print ("Patched f():", A().f())
    print ("Patched g():", A().g(), end="\n\n")

print ("Back to the originals:", (A().f(), A().g()), end="\n\n")
```


## I want to have control over the real thing

The production code I want to exercise uses a method from a class, but I want to determine what it responds to have a constant output and idempotent tests.

This class has other methods and properties I don't care about in this test, but I want to focus only in this specific method.

Solution: We want a Stub, i.e., a canned response to calls. Patch the specific method, receive it in the parameters list and set its `return_value`.

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

The solution above handles the patching of only one method. But if you want to control more than one, I suggest you to patch the entire class and set a `return_value` for each of the methods we want to control.

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

Back to the one-method scenario, if you have several consecutive calls to the method you want to control, and each call should return a different value, you should set the `side_effect` property with a list of values.

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

Yet another similar situation is when you need to force an exception. To get there, set `side_effect` again.

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

Solution: We want a Spy to inspect how things are done under the ground. Patch the specific method or the entire class, receive it in the parameters list and check how it was called.

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

I want to know if some argument was passed to the method, despite the other arguments.

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

That's it. These are the most common uses for the `unittest.mock` library. Obviously I left out many topics about mocking in Python, but surely you can find excelent resources about them in the internet.
