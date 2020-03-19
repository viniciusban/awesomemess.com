---
layout: post
title: The Windows Subsystem For Linux
summary: The complete change in your desktop
featured-img: love-friends
categories: [english]
---

Windows Subsystem for Linux (aka WSL) was a really bold movement from Microsoft and Canonical. It started to change the way we, developers who use Linux in a daily basis, see Microsoft, how we buy our desktop computers and notebooks and where the development focus will be in these years to come.

If you think it did not come to stay, see this page about [Ubuntu on WSL](https://ubuntu.com/wsl) at the official Ubuntu site. Read the arguments and think a little bit.

Some day I will write more about this. For the time being I will focus on the hands-on aspect of WSL.


## How is WSL similar or different from traditional Linux? ##

WSL **is** Linux, but in a different way.

The first difference is that it runs under a lightweight VM, with very little overhead. The performance is very good.

Another difference is it does not run SystemD, so you do not have standard Linux services. If you install, for instance, Postgres or Docker, you cannot manage it through `systemctl` and it will not start automatically when you enter the instance. You have to use the `service` utility to start and stop the service manually. For the same reason, software update does not run automatically.


## How to manage several Linux instances using WSL ##

As WSL instances are virtual machines, we can have many of them installed and running.

We will use the default `wsl` client from the Powershell command line (prompts identified by a `>` symbol). So, you should open it and do not be afraid to type. We are linuxers, after all.

In a nutshell, you can:

- Manage installed distros.
- Install a distro from a `.tar.gz` image.
- Uninstall a distro.


### Manage installed distros

List all installed distros:

```
> wsl --list --all -v
```

Enter a distro:

```
> wsl --distribution MyDistro
```

Shutdown a distro:

```
> wsl --terminate MyDistro
```

Shutdown the WSL VM infrastructure:

```
> wsl --shutdown
```

### Install a distro from a `.tar.gz` file

You can install any number of distros using this method and run them simultaneously. As you do with Vagrant & Virtuabox, for instance.

Download a distro image from https://cloud-images.ubuntu.com/releases/bionic/release/ with the `amd64-wsl.rootfs.tar.gz` termination, e.g., [ubuntu-18.04-server-cloudimg-amd64-wsl.rootfs.tar.gz](https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64-wsl.rootfs.tar.gz).

There is a Ubuntu version delivered through LxRunOffline in https://github.com/DDoSolitary/LxRunOffline/wiki that is a core distribution. It does not come with basic utilities, e.g., sudo, or curl.

Import the `.tar.gz` file to transform it into a working distro:

```
> wsl --import NewDistro c:\my-wsl-distros\new-distro\ c:\Downloads\my-distro-amd64-wsl.rootfs.tar.gz
```

That's all. NewDistro is installed and you can use right away. I recommend you to create a folder in Windows to gather all distros in a single place.

Usually, these images come only with the `root` user enabled. Follow the instructions below to enter NewDistro, create a new user and set it as the default user:

```
> wsl --distribution NewDistro
# adduser john
# adduser john sudo
# echo '[user]' > /etc/wsl.conf
# echo 'default=john' >> /etc/wsl.conf
# exit
> wsl --terminate NewDistro
```

Now you will automatically be the user `john` the next time you open this WSL distro. Check it now:

```
> wsl --distribution NewDistro
```


### Uninstall a distro

**Important notes:**

1. WSL calls it "unregister".
2. The command below will erase the directory you installed the distro in. It will become empty.

Uninstalling a distro is as easy as it was to install it:

```
> wsl --unregister NewDistro
```


## Interoperability between Windows and Linux instances ##

You can start a service inside Linux and access it from Windows transparently. For example, you start nginx inside Linux using the port 8000, open a browser in Windows and access `http://127.0.0.1:8000` to see the web page.

Another very useful scenario is: if you have two (or more) Linux instances running at the same time, one can access the other and Windows can access both as well. Just use `127.0.0.1` (localhost) and the corresponding port everywhere. It is transparent, with zero configuration.


## Which terminal should I use with WSL? ##

The basic Windows' `cmd` works, but I recommend you the new [Windows Terminal](https://github.com/microsoft/terminal) or, better, [Mintty](https://github.com/mintty/wsltty).

You can install [Windows Terminal](https://github.com/microsoft/terminal) from the Microsoft Store. It's quite usable, but not user friendly to customize colours and font.

I usually go with [white background](https://github.com/viniciusban/vim-almostmonochrome) and [IBM Plex Mono](https://www.ibm.com/plex/) font ([Github repo](https://github.com/IBM/plex)) or [Fira Mono](https://mozilla.github.io/Fira/) ([Github repo](https://github.com/mozilla/Fira)).

Personally, I chose [Mintty](https://github.com/mintty/wsltty) as the terminal emulator for WSL because:

- It is simpler to configure colour and font;
- It supports _italics_ (paste it in your Linux terminal: `echo $(tput sitm)italics$(tput ritm)` to check);
- It is quite fast. As far as I have tested, Windows' `cmd` is the faster one, but it is not good to use and to configure.

