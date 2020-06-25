---
layout: post
title: I must not use verbs in RESTful URIs. Or should I?
summary: How to represent business actions using REST.
featured-img: hamlet
categories: [english]
---

People from computing are passionate. We take part in "wars". I am sure you
already saw some: Tabs or spaces? Vim or emacs? Windows or Linux?

Most of them are meaningless, even though there are people saying [developers who use spaces make more money than those who use tabs](https://stackoverflow.blog/2017/06/15/developers-use-spaces-make-money-use-tabs/).

For some time we have seen endless discussions and arguments about if an API
could be considered RESTful. By the way, "REST" and "RESTful" terms can be
confusing. In short, an API is considered RESTful if it conforms to the [REST
specification](https://en.wikipedia.org/wiki/Representational_state_transfer).

To avoid digging deep into one more academic lecture about all characteristics
of RPC and REST APIs, I will define them in a naive way: if one API cannot be
RESTful, it is RPC. In spite of not being fully correct, it is enough for this
post.

Also, I will not discuss the "statelessness" of REST or how to securely
authenticate a user. We are talking about endpoint names and their relation with
business actions.

So, we will make a quick comparison between RPC and REST styles to establish a
starting point and explore some scenarios. They have some key similarities:

- The both run over HTTP;
- Comply with the golden rule of HTTP verbs: `GET` do not change application
  state;
- Embed data to update state into the payload (request body).

Let us examine a few examples below:

|No. | RPC endpoint                            | REST endpoint |
|:--:|-----------------------------------------|---------------|
|  1 | GET /filter_users/?status=active&page=3 | GET /users/?status=active&page=3 |
|  2 | GET /get_user/?id=bob                   | GET /users/bob/ |
|  3 | POST /create_user/                      | POST /users/ |
|  4 | POST /update_product/?id=18             | PUT /products/18/ |
|  5 | POST /delete_item/?id=472               | DELETE /items/472/ |
|  6 | POST /transfer_money/?from=76354gy      |  |
|  7 | POST /change_password/?user=bob         |  |


Briefly, RPC and REST endpoints follow 3 rules, each one following its own path:

- Representation: RPC represents business actions. REST represents resources, not actions.

- State modification: While RPC modifies state using the `POST` verb associated with the action in URL, REST relies mainly on HTTP verbs (`PUT`, `POST`, `PATCH` and `DELETE`) and sometimes in the payload.

- Arguments: in RPC arguments go with query string to allow the execution of the action. In REST they identify a resource and — exactly because of that — are part of the URI. But auxiliary arguments are kept in the query string.

Despite some controversy about `PUT` or `POST` for object creation, the real
discussion is on examples 6 and 7. I did not write their REST version on
purpose. That is what we are going to focus from now on.

RPC-based APIs are good to perform transactions (a.k.a, processes or actions)
over data. REST-based style are designed to represent a domain and perform CRUD
operations on it, but when we need to map business actions to REST
representations, people disagree.

I picked 2 reasonings about an ancient "problem" on REST APIs, the Virtual
Machine problem:

- [RESTful Casuistry](https://www.tbray.org/ongoing/When/200x/2009/03/20/Rest-Casuistry)
- [How does a REST API fit for a command/action based domain?](https://softwareengineering.stackexchange.com/questions/338666/how-does-a-rest-api-fit-for-a-command-action-based-domain)

I strongly recommend you to read them carefully. In short, "the Virtual Machine
problem" raises a question about how to perform operations on a virtual machine
using a REST API. How to map "start vm", "shutdown vm" (and so on) actions in a
REST style, since they are essentially actions, not resources?

Using the `/transfer_money/` endpoint (example 6) as a case, we see some alternatives to translate it into REST:

1. Create a transaction on an account: `POST /accounts/76354gy/transactions/`;
2. Include the verb in URI: `POST /accounts/76354gy/transfer_money/`;
3. Include the verb in query string: `POST /accounts/76354gy/?action=transfer_money`.

Things get worse when we analize the `/change_password/` endpoint (example 7). Should we have `POST /users/bob/change_password/` or `PUT /users/bob/password/`? Note that both endpoints should receive current password for validation, but it will not be persisted.

Like it or not, REST took the world (despite GraphQL momentum in the last years) and we need to perform business actions in REST-based APIs.

So, how to represent business actions using REST?

I will not give an answer, but we will see what the bigger players do. Reading [Twitter](https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference), [Spotify](https://developer.spotify.com/documentation/web-api/reference/playlists/) and [LinkedIn](https://docs.microsoft.com/en-gb/linkedin/shared/api-guide/concepts/methods?context=linkedin/context) documentation we realize there is no "one size fits all" solution to this case.

Spotify looks more RESTful, but they do not have too much "procedural" endpoints available.

LinkedIn, as Spotify as well, tries to adhere to REST as much as possible, but they have a so-called ["ACTION" method](https://docs.microsoft.com/en-gb/linkedin/shared/api-guide/concepts/methods?context=linkedin/context#action-actionname), literally defined as

> "a flexible method that does not specify any type of standard behavior."

Twitter documentation [explicitly says](https://developer.twitter.com/en/docs/basics/things-every-developer-should-know):

> **The API aims to be a RESTful resource**
>
> With the exception of the Streaming API and Account Activity webhooks, the Twitter API endpoints attempt to conform to the design principles of Representational State Transfer (REST).

Did you see the word "aims" in the title? It means _"we try to adhere to these principles as far as they do not stand in our way"_.

It reminds me some topics in [The Zen of Python](https://www.python.org/dev/peps/pep-0020/):

> Special cases aren't special enough to break the rules.
>
> Although practicality beats purity.

It seems Twitter engineers know this message and, yes, you can break the rules. Instead of struggling with unecessary complexity just for purism sake, they chose to build a practical and simpler API. Is it RESTful? "RPCful"? You name it. In the end it must work.

One lesson I learned is: do not pick a side blindly.

When someone asks you if your API is RESTful you may answer "it depends", and start a conversation instead a war.

For further reference, I selected some material you can or cannot agree with. Read them up to have your own opinion:

- [Understanding RPC Vs REST For HTTP APIs](https://www.smashingmagazine.com/2016/09/understanding-rest-and-rpc-for-http-apis/)
- [Best Practices for Designing a Pragmatic RESTful API](https://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api)
- [Represent actions(verbs) in REST URI](https://softwareengineering.stackexchange.com/questions/181545/represent-actionsverbs-in-rest-uri)
- [designing actions in REST API - when is RESTful too RESTful?](https://stackoverflow.com/questions/6704778/designing-actions-in-rest-api-when-is-restful-too-restful)
- [RESTful Resource Naming](https://www.restapitutorial.com/lessons/restfulresourcenaming.html)

REST in peace.
