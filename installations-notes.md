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
