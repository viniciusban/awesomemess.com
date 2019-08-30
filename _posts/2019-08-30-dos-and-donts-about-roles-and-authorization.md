---
layout: post
title: Do's and don'ts about roles and permissions
summary: How to decide what to do based on current user?
featured-img: key
categories: [english]
---

"Do's and don'ts" is a controversial expression. [There's no consensus](https://www.quickanddirtytips.com/education/grammar/dos-and-donts) about how to write it correctly. We read some variations:

- dos and don'ts
- do's and don'ts
- do's and don't's

None of them is substantialy wrong, but some people feel more comfortable with one than the others.

Not as controversial as the title, this post analizes some ways to decide how the system should behave depending on who is using it, or what the user could access or see. Sometimes people tend to adopt practices that don't seem optimal the to check user authorization.


## Authentication and authorization

First of all, let's distinguish two concepts: authentication and authorization.

Authentication is the process to authenticate a user. I.e., check if a given username and password match, for exemple.

On the other hand, authorization is the process to assert some user has the right to access some feature or to perform some action.

In spite of being necessary to authenticate a user to check if she can access some feature, we'll analize only authorization in this post.

In Python world, Django and Web2py (both are web frameworks) bring an embedded user authentication and authorization system. In this post I'll use Django in examples, but the concept is the same, regardless of framework or programming language.


## Roles and permissions

There are a plenty of authorization schemes over there. One of the most used among information systems is the [Role Based Access Control](https://en.wikipedia.org/wiki/Role-based_access_control), a.k.a, RBAC.

Fundamentally, RBAC has 3 main parts:

1. Users
2. Permissions
3. Roles

A user may have many permissions and a permission may be given to many users. Controlling users and permissions individually is a tedious and error-prone task.

As you can imagine, many users may have the same "profile", e.g., managers, clerks, sellers, and so on. Managers can perform actions a clerk cannot. Clerks must have access to features inappropriate to a seller. These profiles are called "roles".

RBAC simplifies administration associating permissions to roles (profiles), instead of to users directly. So, a user is linked to roles and a role has permissions. Put it in another way, a user has permissions through a role.

Note: Django and Web2py use the word "group" to represent a role.


## Additions and shortcuts

Authorization systems aren't limited to roles and permissions. Some have attributes serving as shortcuts and unfortunately people mix concepts.

Taking Django auth as an example, every user has a `is_superuser` attribute. It
is a shortcut to say a user has all possible permissions, even if not
explicitly assigned to her. A superuser has superpowers. If you want some user
to become a superuser, set this flag and the magic happens. You want to revoke
superuser status from a user, unset the flag and you turn her into a "normal citizen"
again.

In practice, if a user is a superuser, Django auth returns `True` for any inquiry about her permissions.


## Roles or permissions?

All this explanation prepare us to handle authorization in our systems. So, how should you check if a user can perform some action or how the system must behave?

Django has methods and decorators to check if a user has a permission and, also, if she is associated with a group.

Checking permissions is the recommended way to authorize (or deny) access to features.

But, many people check if a user has some role to decide what the system should perform or show in screen. Or, using Django auth terms, they check if a user is associated to a group.

I don't recommend this approach due to reasons detailed below, in following examples.


## Notify the administrator

Suppose if a user isn't a manager, the system should send an email to notify the administrator when some data is saved. It's very common to see a snippet like this:

```
# checking user groups

if form.is_valid():
    form.save()
    if request.user.groups.filter(name="managers").count() == 0:
        # send email
```

But there's a better approach:

```
# checking user permission

if form.is_valid():
    form.save()
    if request.user.has_permission("app.can_save_without_notification"):
        # send email
```

Why the second is better?

Let's suppose the business rule changed and, from now on clerks can also save without disturbing the administrator.

If you are checking user groups, you should search all your codebase, modify it to check for managers and clerks and test them all. Probably you should change your automated tests, too.

But if you're checking user permission, no change is necessary to the source code. You only need to assign the "app.can_save_without_notification" permission to the clerks group and we're done.

An additional advantage is the system administrator can personalize permissions. Let's say there's a very experienced user, who isn't a manager, but very conscious of what she is doing. The administrator knows her and trust her. This user could gain the right to save data without disturbing the administrator, even not being a manager.


## Can edit all or only some fields

Let's see other example: superusers can edit all fields in a form. Other users can edit only some, not all:

```
# check who the user is

if request.user.is_superuser:
    # set all fields as editable
else:
    # set only some fields as editable
```

and

```
# check user permission

if request.user.has_permission("app.can_edit_all_fields"):
    # set all fields as editable
else:
    # set only some fields as editable
```

Again, let's consider changing the business rule (it happens all the time!): now, managers can edit all fields, too.

If you are checking who the user is, the source code must be searched, modified and tested.

But, if you're checking user permission, you should only assign "app.can_edit_all_fields" permission to the managers group. That's all.


## Show homepage according to user profile

Another very common situation is showing a different homepage depending on current user:

```
# checking user

def index(request):
    if not request.user.is_authenticated:
        return render("public_homepage.html")
    if request.user.is_superuser:
        return render("superuser_homepage.html")
    if request.user.groups.filter(name="managers").exists():
        return render("managers_homepage.html")
    return render("others_homepage.html")
```

On the other hand:

```
# checking permission

def index(request):
    if not request.user.is_authenticated:
        return render("public_homepage.html")
    if request.user.has_permission("app.can_see_superuser_homepage"):
        return render("superuser_homepage.html")
    if request.user.has_permission("app.can_see_managers_homepage"):
        return render("managers_homepage.html")
    return render("others_homepage.html")
```

This solution is more controversial because the benefit isn't so clear like all previous ones. Personally I check permission for this scenario, too, to follow a standardized way to decide system behaviour.

Not only for standardization sake, this decision could be done in other situations, like, contents of an email, layout of a report, access to some confidential data (e.g, salary or bonus), and so on.

I always chose to check for permission.


## Conclusion

I recommend you to always do check for permission and don't inspect who the user is.

After all, it doesn't matter who is coming. If she has the key to open the door, let it be.

So, don't ask for who is using your system. Check what permission she has.
