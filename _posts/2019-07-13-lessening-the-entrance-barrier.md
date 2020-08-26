---
# published: false
layout: post
title: Lessening the entrance barrier
slug: entrance-barrier
featured-img: high-wall-of-mehrangarh-fort
summary: Lessons learned from choosing a new platform for my blog.
categories: [english]
---

When I decided to start my blog anew in a modern platform, I envisioned a simple entrance. Just open the door and enter.

I established a few pre-requisites:

- I must own the texts. Medium is out;
- It must be simple to manage;
- It must run as fast as possible. Preferably serving static pages;
- It must be beautiful.


## The quest

Surely, static site generators came to the ring. I read good reviews about [Jekyll](http://jekyllrb.com), [Pelican](https://blog.getpelican.com/) and [Hugo](https://gohugo.io/). All of them would be a good choice:

1) Pelican is based on Python. As I am a Python programmer, it was natural to me.

2) Hugo is based on the Go language. People say it is really fast to generate the pages.

3) Jekyll is based on Ruby. The Ruby community launches beautiful designs.

Despite Pelican being the easier option to me, I didn't choose it. I don't want to tune things. I am an end-user here.

Hugo is fast, but speed doesn't matter much in this case because I don't write posts every day. As the site will be served static, Go's speed isn't important.

So, Jekyll won. People craft awesome, professional free themes for it. I found beautiful ones [Jekyll Themes](http://jekyllthemes.org/). This one (when I wrote this post) is [Sleek](https://github.com/janczizikow/sleek/fork).


## Dirty hands

The next step is to look for a good tutorial teaching me how to enter this new room. I know nothing about Ruby and I never used a static site generator before.

Fortunately, I found an [excellent tutorial](https://jtemporal.com/do-tema-ao-ar/) written by [Jessica Temporal](http://jtemporal.com) in Brazilian Portuguese (my native language).

Things seemed easy but, just in case, I decided not to pollute my working environment with new software only to use in my blog. Besides, I will try it before I eat it. So, I launched a virtual machine using Virtualbox & Vagrant.

With Jessica's tutorial in one window and the VM console in the other, let's follow along and install all the stuff to run my so expected new blog.

Ruby didn't installed in the first try because `make` was missing. The Vagrant box I am using doesn't have a basic development package. OK, it's normal. Let's install it:

```
$ sudo apt install -y build-essential
```

Now, Ruby and Rubygems installed perfectly. Level 1 passed.

Jekyll and Bundler hit me in the stomach. Their installation failed:

```
$ gem install jekyll bundler
Fetching: public_suffix-3.1.1.gem (100%)
ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /var/lib/gems/2.5.0 directory.
```

As Rubygems is the package manager for Ruby (like Pip is for Python), I realized it tried to install those libraries system-wide. BTW, Ruby packages are "gems". Cool.

This error started my first Google session to find out how to solve this problem.

As noted earlier, Python would be much simpler to me because I've already tamed the beast for some time. I stopped for a moment, evaluating my choice, thinking about going with Pelican. It lasted not more than one second. Let's continue googling.

I found some advice to solve my problem, but things were going complicated. I didn't know how to efficiently search for information because I don't know Ruby jargon. So, I decided to read the official reference: the [Jekyll Installation](https://jekyllrb.com/docs/installation/) instructions. We all like tutorials and Stackoverflow. They are good shortcuts, but sometimes aren't generic (or specific) enough and the official documentation makes our day.

There are specific [instructions targeting Ubuntu](https://jekyllrb.com/docs/installation/ubuntu/), my current environment. Following them I got Jekyll and Bundler installed successfully.

As a follow-up, Rubygems should be installed under the user's home directory to avoid that problem. Like `pip install --user <package_name>` in Python as well.

So, why go back to my comfortable Python chair if I have the web at my disposal to answer all questions? Level 2 passed. Let's move on!

The "difficult" part was over. Now we'll download the theme and run Jekyll, I thought.

My delusion came with `bundle install`. A new error popped at my screen:

```
$ bundle install
Traceback (most recent call last):
        2: from /home/vagrant/gems/bin/bundle:23:in `<main>'
        1: from /usr/lib/ruby/2.5.0/rubygems.rb:308:in `activate_bin_path'
/usr/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
```

This error was the hardest to solve. I had to learn some Ruby environment specificity to discover what was going on. It seems Rubygems v2 changed some internals and my version is 2.0.2:

```
$ gem list bundler

*** LOCAL GEMS ***

bundler (2.0.2)
```

To solve:

```
$ gem install bundler -v '~>1.12'
$ gem uninstall bundler -v 2.0.2
$ gem list bundler

*** LOCAL GEMS ***

bundler (1.17.3)
$ bundle install
...
Bundle complete! 4 Gemfile dependencies, 21 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

Now, yeah! Let's run Jekyll.

```
$ bundle exec jekyll serve
Configuration file: /vagrant/fresh/_config.yml
            Source: /vagrant/fresh
       Destination: /vagrant/fresh/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
                    done in 0.918 seconds.
 Auto-regeneration: enabled for '/vagrant/fresh'
Configuration file: /vagrant/fresh/_config.yml
    Server address: http://127.0.0.1:4000/fresh/
  Server running... press ctrl-c to stop.
```

Nice! Nobody stops me now! Let's head to http://127.0.0.1:4000/fresh/ in my browser.

Uh-oh!

![Jekyll connection reset]({{ site.baseurl }}{{ site.img_dir }}/posts/jekyll-connection-reset.jpg)

One more Google session to discover that under Vagrant, the command should be:

```
$ bundle exec jekyll serve --host 0.0.0.0
```

Finally, the blog homepage showed up!

![Fresh blog]({{ site.baseurl }}{{ site.img_dir }}/posts/fresh-blog.jpg)

From now on all instructions at Jessica's tutorial worked as expected. I created my Disqus account, uploaded my repository to Github, configured Github Pages and redirected my domain. Everything straight.

I'm happy.


## Defaults don't suffice for a programmer

Did I mention I am a programmer?

These creatures do like to customize things. Each one of us has a different dotfile. Each one of us changes the editor font. We don't stop with the defaults. Running is not enough, it must run with our personal touch.

So, why stick with the theme Jessica brilliantly chose in the tutorial?

Recapping, I followed a really good Jessica Temporal's tutorial on how to launch a Jekyll blog from scratch, with some additional help from the world _wise_ web. I already have a default version of my new blog running in Github Pages under my domain. All working nicely.

After some search with really good designs at the  [Jekyll Themes](http://jekyllthemes.org/) site, I choose [Sleek](https://github.com/janczizikow/sleek).

It's beautiful, simple, SEO friendly, can integrate Google Analytics, Disqus comments... I go with it.

Now I'm walking in an unknown path. I left Jessica behind (sorry for that). From now on it's at my own risk. After all, I am a developer!


## Blood, sweat and tears

Opening Sleek's README, I faced a weird requirement: **NodeJS (8 or greater)**.

![nodejs wat?!]({{ site.baseurl }}{{ site.img_dir }}/posts/nodejs-wat.gif)

I wanted a modern layout, but in these complicated days we live now, "modern" usually means "bloated". NodeJS?! If it was something simple like JQuery, OK. Probably the pages would use it. But NodeJS?!

After unburdening, let's install the latest LTS (by the writing of this post), NodeJS 10. I always go with LTS versions. It can't be wrong.

Despite Gulp being optional, I decided to install it. I wanted it all.

Problem here. Guess what? Python is needed! hahaha. I didn't want Python, but Gulp (new to me, too) wants it.

This Vagrant box doesn't come with Python 2, what Gulp needs. OK, I installed Python 2. Let's `npm install --global gulp-cli` again.

Oh, no! Gulp doesn't work with the latest NodeJS LTS. Why? Why developers do these things? Programmers!

Let's uninstall NodeJS LTS (it couldn't be wrong, remember?) and install an older version. I downgraded to NodeJS version 9. Now I discovered why NodeJS is required. Gulp is the villain.

Well, as Gulp installed successfully, the time arrived to run Jekyll again and see the new blog theme.

To my surprise, it worked! (See it at the [live demo](https://janczizikow.github.io/sleek/)).

After so many frustrations, I didn't celebrate this time. Instead of a "wow!" moment, I got an "OK, it runs" one.

I confess I could make basic customizations and created some posts, showed some images, but I was waiting for the next problem, and it came. 

Reading the docs, I realized Sleek can generate several sizes from your original image. Simply put them at the `_img/posts` directory and run

```
$ gulp img
```

So, I discovered why Gulp (and NodeJS, for that matter) are required: to generate different image sizes. It's useful. Then I stopped complaining about them.

I told you I was expecting, more problems, right? For some strange reason, some node packages didn't install correctly. I only removed `node_modules/` directory and `npm install`'ed again.

This time everything was fine and I could optimize images and replace my previous blog (remember Jessica's tutorial) with this new one.

Victory!


## Lessons learned

You are reading this article here because Jessica made a great job in her tutorial, amazing people developed Jekyll, wonderful themes and the open-source community is amazing. Additionally, publishing on Github Pages is extremely simple. Ironically, a piece of non-open source software in this toolchain.

Despite all those great work, things didn't fit well when put in context. For instance, it is simple to install Ruby, but the environment should be prepared to send Rubygems to the right place.

I started this journey looking for a simple way to create my new blog. Only due to bad past experiences, I decided to make all of this in a virtual machine. In hindsight, it was a wise decision. Otherwise, I could have messed with the computer I use to work on.

I expected everything was straightforward, but things weren't so smooth. I had to install Ruby, Nodejs and Python. Three different languages! I faced some problems, googled a lot, learned some intricacies... all of it to pave a road to write my posts and show them beautifully.

As I am addicted to automation, I created scripts to handle that and I won't see these problems again in a while. But how frustrating things can be! I know by experience every beginning has its traps. This wasn't different.

The motto must be never give up and never be condescending with complexity and, to a broader extent, complication.


Don't get me wrong. I'm an enthusiast of open-source software, but usability
matters a lot. Sometimes all we want are "things that simply work". That's why
some old software experiences a revival. We saw it in macOS. BSD was its
foundation and now it's more used in desktops than in servers. We saw it again
years ago when Ubuntu debuted, simplifying Linux installation. We are seeing
it again, witnessing the success of elementary OS, is self-claimed a
replacement for Windows and macOS, which is based on Ubuntu and in Linux Mint,
for instance.

Usability counts.

Another lesson to me was choosing Jekyll because of the themes. The appearance was important and technical details didn't matter to me. I haven't technically analyzed the 3 candidates. I also didn't analyze their simplicity. I chose what I was seeing. I don't know why, but Ruby products are much more visually appealing than their Python counterparts. Maybe other communities have something to learn with them.

Finally, I want to use simpler things. I also **must** build simpler things with small entrance barrier to novices. People are greater, but high barriers make us feel small.

> "The simpler I keep things, the better I play."
>
> &mdash; <cite>[Nancy Lopez](https://en.wikipedia.org/wiki/Nancy_Lopez)</cite>, an American professional golfer.


