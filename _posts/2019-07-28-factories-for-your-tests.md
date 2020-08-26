---
layout: post
title: A Pythonic approach to produce test data
summary: Things can become complicated when generating test data, but Python helps us achieve a very simple way.
slug: test-factories
featured-img: blue-sky-chimney-clouds-208714
categories: [english]
tags:
  - english
  - python
  - test
  - tests
  - factory
---

You write automated tests for your system and realize many fixtures (a.k.a, test data) are similar to each other. Then, you decide to write functions to produce them in a standardized way. How would you implement these factories? Should you use simple functions or would classes be better in this case?

Let's suppose we want to generate test data to an `Employee` with 4 attributes. The class definition is:

```
class Employee:
    name = ""
    species = ""
    company = ""
    department = ""

    def __init__(self, **kwargs):
        self.name = kwargs["name"]
        self.species = kwargs["species"]
        self.company = kwargs["company"]
        self.department = kwargs["department"]

    def __str__(self):
        return self.name
```

The `Employee` class could be a Django or a SQLAlchemy model. Python has several good options to create classes like this one. Named tuples and dataclasses are some of them, but for teaching purposes I'm using a simple class in this article. The goal here is to provide you with the very basic concepts.

A factory should do some work for us. Usually, it uses some default values to avoid duplication in tests.


## The very basic

The most obvious and first approach would be writing a simple function, like this:

```
def EmployeeTestFactory():
    return Employee(
        name="John Smith",
        species="human",
        company="ACME Corporation",
        department="unknown",
    )
```

Now you have a factory building an `Employee` instance with default data. You can call it this way:

```
employee = EmployeeTestFactory()
```

Yet being very simple and attending extremely basic cases, it has an obvious limitation: if you want to use some custom value in a given attribute, you must modify the returned instance:

```
employee = EmployeeTestFactory()
employee.name = "Mary Poppins"
employee.company = "Walt Disney Co."
```

As we can see, changing several attributes makes your test much more verbose and it has almost no advantage than instantiating the object by itself. Besides that, mutability is frequently a bad idea, so let's move forward to a better alternative.


## Passing custom values

```
def EmployeeTestFactory(**kwargs):
    data = {
        "name": "John Smith",
        "species": "human",
        "company": "ACME Corporation",
        "department": "unknown",
    }
    data.update(kwargs)
    return Employee(**data)
```

This new version allows us to create an `Employee` without modifying the resulting instance, simply passing those values we want to customize:

```
mary = EmployeeTestFactory(name="Mary Poppins", company="Walt Disney Co.")
```

Much better, right? All others attributes assume their respective defaults.

But when creating similar objects (very common situation in tests), we incur in some repetition:

```
mary = EmployeeTestFactory(name="Mary Poppins", company="Walt Disney Co.")
mickey = EmployeeTestFactory(name="Mickey", company="Walt Disney Co.", species="mouse")
```

What do Mary and Mickey have in common? They both work at the same company. How about creating them without repeating the `company` argument?


## Factories for the win

It would be nice to create those instances of `Employee` this way:

```
disney_factory = EmployeeTestFactory(company="Walt Disney Co.")
mary = disney_factory(name="Mary Poppins").build()
mickey = disney_factory(name="Mickey", species="mouse").build()
```

We got rid of the repeated argument `company`. Instead, now we have the `disneys` variable. Its usefulness is twofold:

1. Clarifies our intention to have Walt Disney's employees. Names are important and bring context.
2. Serves as the foundation to build all employees from the same company.

Let's see a pythonic way to enable this syntax in sessions below.


## A real factory

First of all, we'll transform our factory into a class and add a couple methods, giving it the power to create similar instances without code repetition.

Until now our factory returned only the class instance we wanted. Despite it's being enough for almost all cases, a real factory should be more flexible. So, from now on we'll differentiate two roles:

1. The factory
2. The instance builder

The factory always returns a factory instance. This is what `__init__()` and `__call__()` methods below do.

```
class EmployeeTestFactory:
    defaults = {
        "name": "John Smith",
        "species": "human",
        "company": "ACME Corporation",
        "department": "unknown",
    }

    def __init__(self, **kwargs):
        data = self.defaults.copy()
        data.update(kwargs)
        self._data = data

    def __call__(self, **kwargs):
        data = self._data.copy()
        data.update(kwargs)
        return self.__class__(**data)
```

What's the difference between `__init__()` and `__call__()`? It's subtle, but important: `__init__()` use defaults from the class while `__call__()` use data from the instance.

The instance builder uses the data passed to the factory and builds the instance we're looking for, through the `build()` method.

Let's see the code:

```
    # all the same as above code snippet

    def build(self):
        return Employee(**self._data)
```

To have an instance of `Employee`, we should use `build()`, like below:

```
smith = EmployeeTestFactory(name="Mr. Smith").build()
```

But, when calling `EmployeeTestFactory` without `build()`, we get an instance of the factory itself (`EmployeeTestFactory`). This separation allows us to have many factories with distinct characteristics:

```
disney_factory = EmployeeTestFactory(company="Walt Disney Co.")
journalist_factory = EmployeeTestFactory(
    company="Daily Planet",
    department="journalism"
)
```

Now we can use the instance builder to have the instances we want:

```
mary = disney_factory(name="Mary Poppins").build()
clark = journalist_factory(name="Clark Kent").build()
lois = journalist_factory(name="Lois Lane").build()
```

There's one more aspect we haven't explored until now. The `__call__()` method. It allows us to create a factory based on another factory, like this:

```
disney_factory = EmployeeTestFactory(company="Walt Disney Co.")
human_factory = disney_factory(species="human")
mouse_factory = disney_factory(species="mouse")
```

`human_factory` and `mouse_factory` are based on `disney_factory`. Now we can do this:

```
mary = human_factory(name="Mary Popppins").build()
peter = human_factory(name="Peter Pan").build()

mickey = mouse_factory(name="Mickey").build()
minnie = mouse_factory(name="Minnie").build()
```

The advantage of this approach is we can create similar objects using a very clear syntax, making our tests more readable.

## Going deeper

If your base factory is used in many places you could create a specific factory, adding a class method, like this:

```
class EmployeeTestFactory:

    # Everything we have already written

    @classmethod
    def disney_factory(cls, **kwargs):
        data = {"company": "Walt Disney Co."}
        data.update(kwargs)
        return cls(**data)
```

And use it this way:

```
human_factory = EmployeeTestFactory.disney_factory(species="human")
mouse_factory = EmployeeTestFactory.disney_factory(species="mouse")
```



## The complete version

Finally we have the complete version:

```
class Employee:
    name = ""
    species = ""
    company = ""
    department = ""

    def __init__(self, **kwargs):
        self.name = kwargs["name"]
        self.species = kwargs["species"]
        self.company = kwargs["company"]
        self.department = kwargs["department"]

    def __str__(self):
        return self.name


class EmployeeTestFactory:
    defaults = {
        "name": "John Smith",
        "species": "human",
        "company": "ACME Corporation",
        "department": "unknown",
    }

    def __init__(self, **kwargs):
        data = self.defaults.copy()
        data.update(kwargs)
        self._data = data

    def __call__(self, **kwargs):
        data = self._data.copy()
        data.update(kwargs)
        return self.__class__(**data)

    def build(self):
        return Employee(**self._data)

    @classmethod
    def disney_factory(cls, **kwargs):
        data = {"company": "Walt Disney Co."}
        data.update(kwargs)
        return cls(**data)
```


## Some valid questions

Q: Why do we use factories if we have `unittest.mock.Mock` in Python?

A: Factories and mocks aren't mutually exclusive. Actually, they complement each other. It's common to use double Model instances created by factories to populate data returned by mocked functions. This practice avoids touching the database and speeds up the tests.

Q: Why use factories if we have [ModelMommy](https://model-mommy.readthedocs.io/en/latest/) and [factory_boy](https://factoryboy.readthedocs.io/en/latest/)?

A: Those libraries are very powerful and I recommend using them. Personally, I do. As mocks, ModelMommy and factory_boy don't kill factories. That's quite the opposite. As mocks, they don't bring context to your fixtures because they don't have this goal. That's what factories are for: bring context to fixtures and clarify the intention of your test. Remember from [The Zen of Python](https://en.wikipedia.org/wiki/Zen_of_Python), _"Explicit is better than implicit"_.

Q: Isn't it too complicated to get only a copy of an instance?

A: Not at all. As we demonstrated, we can create many factories based on specific cases, simplify our tests and let their intention much more explicit.


## Conclusion

We learned why separating the factory from the builder is a good idea to simplify test methods and clarify their intentions.

Also, we learned how to write a powerful factory class that doesn't mutate state, create a copy of itself with some different values and builds an instance of the target class.

Last but not least, we saw some Python tricks (classmethod, kwargs, `__call__()`, etc.) that enable a powerful and simple codebase.

Note: This post is based on the Chapter Constructing Complex Test Data of the great book [Growing Objected-Oriented Software, Guided by Tests](http://www.growing-object-oriented-software.com), by [Steve Freeman](https://twitter.com/sf105) and [Nat Pryce](http://www.natpryce.com).
