---
layout: post
title: Mocking in Python
summary: An "I want to" approach to straight use of the Python's mocking library.
featured-img: eyeglasses
categories: [english]
---

In this article about Python's built-in `unittest.mock` library, I address my personal needs in a very practical way to handle mocking in Python. It is guided by, and based on questions that usually arise when I am writing tests that use mock objects.

When we talk about mocks, we are really talking about "stunt doubles". They work in movies, replacing the main actors in dangerous scenes and usually look like them. If a stunt double gets hurt, the audience will not perceive that an accident has occurred, because the original actor will continue appearing in the movie consistently. Therefore, a stunt double is someone who replaces and preserves the “actual” actor.

We also appreciate stunt doubles in automated software tests. We call them "test doubles". They help us test features (class method or function), playing important roles. Depending what they do in each situation, we call them by different aliases: dummy, fake, stub, spy or mock. If you are unfamiliar with this classification, I suggest you read a great article by Martin Fowler, [Mocks aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html#TheDifferenceBetweenMocksAndStubs).

Usually, test doubles are helpful to:

1. Ignore some class or method used by your code under test, but unimportant in some test;
2. Configure what a specific method returns;
3. Check if a method was called by the code under test.

We will address all these topics, but first you must see a very simple Python class that we will use in the code examples below:

```
class A:
    def f(self):
        return "The real f()"

    def g(self):
        return "The real g()"
```

All tests will use it to demonstrate how to handle mocking in Python.

It is important to say we will not discuss how to use `unittest.mock`. Instead, we will focus on the situations a test double is useful and how to involve them in action.

Thus, let's get started.


## I want to ignore the real thing

We can use a test double to replace some production code we don't want it running for some reason. Maybe because it touches the database, or it accesses an external API. Whatever the reason, the real code must not run. So, test double for the rescue!

When the code under test calls our test double (a "dummy", in this case), no error will happen. This kind of test double is useful to fill some required argument, or to replace some function we use, but isn't important for this very test.

If that replaced code returns some value, we must not care about it. The only behaviour we aim is: do not show any error. It must not be perceived.

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
