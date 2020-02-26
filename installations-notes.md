# Using a vagrant VM #


## Basic

```
sudo usermod -a -G staff vagrant
sudo apt update
sudo apt install -y git
```

Exit and enter again.

## Install ruby

https://jekyllrb.com/docs/installation/ubuntu/

```
sudo apt-get install -y ruby-full build-essential zlib1g-dev
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
mkdir --parent $GEM_HOME
```

## Install jekyll e bundler

https://jekyllrb.com/docs/

```
$ gem install jekyll bundler
```


## Install node v9

https://github.com/nodejs/help/wiki/Installation

```
cd /tmp
NODE_VERSION=v9.11.2
NODE_DISTRO=linux-x64
sudo mkdir -p /usr/local/lib/nodejs
wget https://nodejs.org/dist/latest-v9.x/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz
sudo tar -xJvf node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz -C /usr/local/lib/nodejs 
sudo chown -R root:staff /usr/local/lib/nodejs
echo "export PATH=/usr/local/lib/nodejs/node-${NODE_VERSION}-${NODE_DISTRO}/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc
```

Checking if node is OK:

```
node -v
npm version
npx -v
```


## Install Gulp CLI

```
npm install --global gulp-cli
```

## Install sleek 

```
cd <repo>
gem install bundler -v '~>1.12'
gem list bundler
bundle _1.17.3_ install  # install the 1.xx.y version
gem uninstall bundler -v 2.1.2  # uninstall the 2.xx.y version
bundle install
sudo apt install -y python
npm install
npm install node-sass
```

## Running jekyll

```
bundle exec jekyll build && bundle exec jekyll serve --host 0.0.0.0 --no-watch
```

Now go to http://<vm-ip>:4000/

## Generating multi-sizes images

Run this whenever you add a new image to `_img/posts/` directory.

```
gulp img
```

https://jtemporal.com/do-tema-ao-ar/


---


# Using asdf-vm #

Run all commands below from the project's root directory.



## Install Ruby Stuff ##

Ruby language itself:

```
$ asdf plugin add ruby
$ asdf install ruby latest
$ asdf ruby list
2.7.0
$ asdf global ruby 2.7.0
```

Check if Ruby was successfully installed:

```
$ ruby --version
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux]
```


Set where Ruby gems will be stored:

```
$ export GEM_HOME=${HOME}/.local/rubygems
$ mkdir --parent $GEM_HOME
$ export PATH="${GEM_HOME}/bin:${PATH}"
```

Install Jekyll and bundler:

```
$ gem install jekyll bundler
```


## Install Node.js Stuff ##

Import GPG keys and install Node.js:

```
$ asdf plugin add nodejs
$ bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
$ asdf install nodejs 9.11.2
$ asdf global nodejs 9.11.2
```

Check if Node.js was successfully installed:

```
$ node -v
v9.11.2
$ npm version
{ npm: '5.6.0',
  ares: '1.13.0',
  cldr: '33.0',
  http_parser: '2.8.0',
  icu: '61.1',
  modules: '59',
  napi: '3',
  nghttp2: '1.32.0',
  node: '9.11.2',
  openssl: '1.0.2o',
  tz: '2018c',
  unicode: '10.0',
  uv: '1.19.2',
  v8: '6.2.414.46-node.23',
  zlib: '1.2.11' }
$ npx -v
9.7.1
```

Upgrade `npm` and install Gulp CLI:

```
$ npm i npm@latest -g
$ npm install gulp-cli
```


## Install The Theme ##

We use a theme called "sleek":

```
$ gem install bundler -v '~>1.12'
$ gem list bundler
$ bundle _1.17.3_ install  # install the 1.xx.y version
$ gem uninstall bundler -v 2.1.4  # uninstall the 2.xx.y version
$ bundle install
$ npm install
$ npm install node-sass
```


## Run Jekyll ##

The local server is ready:

```
$ bundle exec jekyll build
$ bundle exec jekyll serve --watch
```

Visit the local blog at `http://localhost:4000`


## Generating Multi-sizes Images ##

Run this whenever you add a new image to `_img/posts/` directory.

```
$ node_modules/gulp-cli/bin/gulp.js img
```

## Entering The Environment ##

Every time you want to run the local Jekyll server, you must run these commands below:

```
$ export GEM_HOME=${HOME}/.local/rubygems
$ export PATH="${GEM_HOME}/bin:${PATH}"
$ alias gulp='node_modules/gulp-cli/bin/gulp.js'
```
