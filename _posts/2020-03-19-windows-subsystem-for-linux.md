---
layout: post
title: The Windows Subsystem For Linux
summary: The complete change in your desktop
featured-img: love-friends
categories: [english]
---

Windows Subsystem for Linux (aka WSL) was a really bold movement from Microsoft and Canonical. It started to change the way we, developers who use Linux in a daily basis, see Microsoft. It can influence which computer we choose to buy and which software we use to be productive.

If you think it did not come to stay, see this page about [Ubuntu on WSL](https://ubuntu.com/wsl) at the official Ubuntu site. Read the arguments and think a little bit.

Some day I will write more about this. For the time being I will focus on the hands-on aspect of WSL.


## How is WSL similar or different from traditional Linux? ##

First of all, WSL **is not** Linux. WSL is an infrastructure to run Linux kernels under Windows as lightweight virtual machines. As its name suggests, it is a subsystem.

The Ubuntu distribution for WSL, for instance, is a real Ubuntu. You manage packages with `apt`, and `bash` is the shell interpreter. Everything works "normal". So normal, that you can install and run Docker (which uses container virtualization: namespaces, cgroups and chroot) in it. However, there are [ways to know you are in WSL](#how-to-know-if-running-under-wsl).

As I said before, things are "normal". Even so, there are differences between a distro running under WSL and a traditional Linux.

One important difference is: WSL distros do not run SystemD, so you cannot have standard Linux services. If you install, for example, Postgres or Docker, you cannot manage them through `systemctl` and they will not start automatically when you enter the distro. You have to use the `service` utility to start and stop services. For the same reason, software update does not run automatically.

Additionaly, WSL distros do not clean the `/tmp` directory. So, be careful. There is no such thing as a fresh `/tmp` on each boot. Keep an eye on your disk space.


## How to manage several WSL distros ##

As WSL distros run as virtual machines, we can have many of them installed and running.

We will use the default `wsl` client from the Powershell command line (prompts identified by a `>` symbol). So, you should open the Windows Powershell and do not be afraid to type. We are linuxers, after all.

In a nutshell, you can:

- Manage distros.
- Install a distro from a `.tar.gz` image.
- Uninstall a distro.


### Manage distros

List all installed distros:

```
> wsl --list --all -v
```

You do not need to "start" a WSL distro. You simply enter it:

```
> wsl --distribution MyDistro
```

Terminate (shutdown) a distro:

```
> wsl --terminate MyDistro
```

Shutdown the WSL VM infrastructure. This command will terminate all running distros:

```
> wsl --shutdown
```

### Install a distro from a `.tar.gz` file

You can install any number of distros using this method and have them running simultaneously, as you would do with Vagrant & Virtuabox, for example.

Download a distro image from <https://cloud-images.ubuntu.com/releases/bionic/release/> with the `amd64-wsl.rootfs.tar.gz` termination, e.g., [ubuntu-18.04-server-cloudimg-amd64-wsl.rootfs.tar.gz](https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64-wsl.rootfs.tar.gz).

There is a Ubuntu image delivered through [LxRunOffline wiki](https://github.com/DDoSolitary/LxRunOffline/wiki) that is a "core distribution". It does not come with basic utilities, like `sudo` or `curl`. You have to install everything you want.

Import the `.tar.gz` file to transform it into a working distro. I recommend you to create a folder in Windows to gather all distros in a single place.:

```
> wsl --import NewDistro c:\my-wsl-distros\new-distro\ c:\Downloads\my-distro-amd64-wsl.rootfs.tar.gz
```

That's all. NewDistro is installed and you can use it right away.

Usually, these images come only with the root user enabled. Follow the instructions below to configure a default user `john`, to avoid using `root` directly:

```
> wsl --distribution NewDistro
# adduser john
# adduser john sudo
# echo '[user]' > /etc/wsl.conf
# echo 'default=john' >> /etc/wsl.conf
# exit
> wsl --terminate NewDistro
```

Now you will automatically be the user `john` every time you enter this distro. Check it now:

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


## Interoperability between Windows and Linux ##

You can start a service inside WSL and access it from Windows, transparently. For example, you start nginx inside WSL using the port 8000, open a browser in Windows and access `http://127.0.0.1:8000` to see the web page.

Another very useful scenario is: if you have two (or more) WSL distros running, one can access the other and Windows can access both as well. Just use `127.0.0.1` (localhost) and the corresponding port everywhere. It is transparent, with zero configuration.


## Which terminal may I use with WSL? ##

The basic Windows' `cmd` works, but I recommend you the new [Windows Terminal](https://github.com/microsoft/terminal) or, better, [Mintty](https://github.com/mintty/wsltty).

You can install [Windows Terminal](https://github.com/microsoft/terminal) from the Microsoft Store. It's quite usable, but not user friendly to customize colours and font.

I usually go with [white background](https://github.com/viniciusban/vim-almostmonochrome) and [IBM Plex Mono](https://www.ibm.com/plex/) ([Github repo](https://github.com/IBM/plex)) or [Fira Mono](https://mozilla.github.io/Fira/) ([Github repo](https://github.com/mozilla/Fira)) fonts, so I need some easyness on this.

You can see below a small comparison I made on important features for me:

| Feature | Windows cmd | Windows Terminal | Mintty |
|---------|-------------|------------------|--------|
| easy to configure colours | yes | no | yes |
| easy to configure font | yes | no | yes |
| speed | faster | fast | fast |
| support _italics_ | no | no | yes |
| click on a link and open it in browser | no | no | yes, with Shift + Control + click |

Well, why would italics be an important feature? Because I configure my editor to show comments and strings in italics. I like it.

Tip: paste this snippet in the terminal to check if it supports italics:

```
$ echo $(tput sitm)it must appear in italics$(tput ritm)
```

Finally, my personal choice is Mintty.


## How To Know If Running Under WSL ##

There are ways to know if you are running a Linux distro under WSL.

[The official way](https://github.com/microsoft/WSL/issues/423#issuecomment-221627364) recommends looking for "Microsoft" in the kernel release:

```
$ uname -r
4.19.84-microsoft-standard
```

But as we see above, you should check for "microsoft" with all letters in lowercase. Here is an example:

```
$ uname -r | grep -i microsoft
```

When you inspect the bash environment, you see some useful variables there:

```
$ env | grep WSL
WSL_INTEROP=/run/WSL/18_interop
WSL_DISTRO_NAME=Ubuntu-18.04
WSL_GUEST_IP=172.31.132.120
WSLENV=
```

