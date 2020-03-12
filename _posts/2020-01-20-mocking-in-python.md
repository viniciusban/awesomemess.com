---
layout: post
title: Mocking in Python
summary: An "I want to" approach to straight use of the Python's mocking library.
featured-img: lego-stunt-double
categories: [english]
---

In this text about Python's built-in `unittest.mock` library, I address my personal needs in a very practical way to handle mocking in Python.  It is guided by, and based on questions that usually come to me when I am writing tests that need to use test doubles.


## Behind The Names

I believe that naming things correctly is at the core of software development. Since there are a wide variety of terms about software tests, and to avoid misunderstanding, it is necessary to set up a convention.

**Code under test** is our target i.e., the code we want to test. It normally is a method or a function.

**Collaborator code** helps the code under test, usually being called by it.

Both code under test and collaborator code are the **production code** i.e., the code that will run in production.

**Test code** is the code we write to exercise — aka call —, the code under test and make assertions about its behaviour or its result. For instance, to check if the `apply_discount_on_first_order()` function decreased the price as expected.

**Test double** is a "stunt double" that replaces the collaborator code as a way to run a test code.

All of the above terms are self-explanatory to someone writing tests, except the test double. Therefore, please read the explanation below to further understand its importance to tests.

In the cinema industry, stunt doubles look similar to the main actors and their job is to replace them in some scenes. Stunt doubles exist to protect the main actors from injuries, or to accomplish actions they are not capable of. Somehow, a test double works like a stunt double. However, it only replaces the "actor" during the test phase, but never in production.

Since the roles of a test double can vary, several terms were created to distinguish them, e.g.: _dummy_, _fake_, _stub_, _spy_, and _mock_. If you are unfamiliar with this classification, I suggest you read a great text by Martin Fowler, [Mocks aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html#TheDifferenceBetweenMocksAndStubs).

As we now have all pieces named accordingly, we can jump into the scenarios where test doubles are commonly helpful to simplify the tests.


## I Want To Avoid Some Function From Running

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
            report_who_have_salary_raised(e)
```

We will consider a scenario to test a single aspect of the function above: assert people hired less than 15 years ago do not have their salary raised.

To build this test, we must:

1. Populate the database with one employee hired less than 15 years ago;
1. Call the code under test, i.e, the `raise_salary()` function;
1. Check the employee keeps the same salary.

Straightforward, right? But we must take account of one detail: the code under test calls `report_who_have_salary_raised()`, which is a collaborator function we do not want to run, because it is not important in this test. As we should not modify the code under test to stop calling it only to run the test, we have to find another solution.

The situation we are facing is we will run the code under test but `report_who_have_salary_raised()` should not be called or, even if called, it should do nothing.

The solution we will adopt is replacing `report_who_have_salary_raised()` at run time with another callable with the same name, but that does absolutely nothing. A **dummy object**. In other words, we will make the code under test call another function with the same name as the original one, instead of modify the code under test. But this namesake will do nothing.

The implementation uses `mock.patch()` as a decorator to replace `report_who_have_salary_raised()` with a `mock.Mock` instance. By default, `Mock` instances do nothing when called. It is definitely what we need:

```
import unittest
from unittest import mock

from repository import Employees
from business_functions import raise_salary

class TestRaiseSalary(unittest.TestCase):
  @mock.patch("business_functions.report_who_have_salary_raised", new=mock.Mock())
  def test_must_keep_same_salary_if_hired_less_than_15years_ago(self):
    e = Employees.create(employee_factory(
      start_date=ONE_YEAR_AGO, department="sellers", salary=100.00
    ))
    raise_salary(department="sellers", percentage=0.10)
    same_e = Employees.get(id=e.id)
    self.assertEqual(same_e.salary, e.salary)
```

Tip: filling the `new` argument in `mock.patch()`, as we did above, avoids receiving the mocked object as a parameter in your test case. This is useful here because we will not touch this mocked function.

The test code above runs the code under test without the inconvenience of a non-desirable action, the `report_who_have_salary_raised()` function. It is replaced by a do-nothing callable, a **dummy object**, provided by `mock.Mock()`.


---

TODO:

- (x) explain what we will do.
- (x) show the code under test.
- (x) tell what we will test.
- (x) describe the steps we must follow to achieve the desired test.
- (x) explain the strategy to mock in this scenario.
- (x) explain how to implement the strategy with a real test case.
- (x) make an overview as the last paragraph.

---



## I Would Like to Test the Function _X_'s Behaviour When _Y_ Returns a Specific Value ##


In this scenario we will use a test double to return a fixed response from a collaborator function.

The code we want to test is this:

```
def discount_for_this_customer(customer_id):
    level = compute_customer_level(customer_id)
    if level == "silver":
        return 0.10
    if level == "gold":
        return 0.20
    return 0
```

The `discount_for_this_customer()` function should give the correct discount for a given customer. As we can see, it depends on the `compute_customer_level()` collaborator function to have the customer's level and, based on that, decide the correct amount.

There are, basically, two approaches to make this test:

1. Simulate a fixed answer from `compute_customer_level()`, ignoring all its complexities;
1. Know the `compute_customer_level()` rules, prepare a customer matching those characteristics in the database and have the desired response.

Let's think for a moment. Which one we want to test: `discount_for_this_customer()` or `compute_customer_level()`? The first one, right? For that reason the rules to compute a customer's level is not important here. Under this point of view, we move towards the first option, i.e., simulate a fixed answer from `compute_customer_level()`.

This choice has a couple of benefits. The obvious one is **simplicity**. The other one, very important but not so obvious at first, is **decoupling**. If we had chosen to prepare a customer with specific characteristics, we would be coupling our test to the internal behaviour of a production code that is out of the current test scope. When `compute_customer_level()` rules change — and they will — suddenly our test could break and we should change the configuration of the customer to adapt it to the new rules. As in life, when possible, always choose the simpler alternative.

So, our test will be very simple. We will:

1. Set a specific response for `compute_customer_level()`;
1. Call `discount_for_this_customer()` with any `customer_id` (more on this later);
1. Assert it returns the correct amount.

In this test we will replace the real `compute_customer_level()` with a **stub object**. It will always return the pre-defined value.

The implementation uses `mock.patch()` as a decorator to replace the real function with a **stub object**:

```
import unittest
from unittest import mock

from business_functions import compute_customer_level, discount_for_this_customer

ANY_CUSTOMER_ID = 1234

class TestRaiseSalary(unittest.TestCase):
  @mock.patch("business_functions.compute_customer_level")
  def test_amount_must_be_010_for_silver_customer(self, mocked_function):
    mocked_function.return_value = "silver"
    amount = discount_for_this_customer(customer_id=ANY_CUSTOMER_ID)
    self.assertEqual(amount, 0.10)

  @mock.patch("business_functions.compute_customer_level")
  def test_amount_must_be_020_for_gold_customer(self, mocked_function):
    mocked_function.return_value = "gold"
    amount = discount_for_this_customer(customer_id=ANY_CUSTOMER_ID)
    self.assertEqual(amount, 0.20)

  @mock.patch("business_functions.compute_customer_level")
  def test_amount_must_be_0_for_other_customer(self, mocked_function):
    mocked_function.return_value = "other level"
    amount = discount_for_this_customer(customer_id=ANY_CUSTOMER_ID)
    self.assertEqual(amount, 0)
```

We have effectively tested all the `discount_for_this_customer()` behaviour in 3 simple and small test methods. Each one managing its own scenario, independent of the others and decoupled from the `compute_customer_level()` details. By the way, it is important to talk a little about the `customer_id`.

You may be thinking why we can use any `customer_id` in the tests above. Because we replaced `compute_customer_level()` with a test double which only returns a canned response and does nothing else. The original function signature did not change, only its response. And the tests do not even touch the database. This is one additional advantage of decoupling the test from the collaborator code: beyond simpler, it is faster.

The tests above exercise the `discount_for_this_customer()` function in three different scenarios. It replaces the collaborator code with a **stub object** to make the tests simpler, focused, decoupled and faster. As every test should be.

---

Note: This is a work in progress. Everything below this point will be revisited and rewritten. Come back soon.

---




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
