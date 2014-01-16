#!/bin/sh

# ami-e9b39a80

set -e

sudo apt-get update
sudo apt-get install vim nodejs phantomjs swig git-core build-essential libssl-dev libsqlite3-dev python-support libmagickcore-dev libmagickcore5 libmagickcore-dev libmagickcore5-extra libbz2-dev  libdjvulibre-dev  libexif-dev  libfreetype6-dev  libgraphviz-dev  libjasper-dev  libjpeg-dev liblcms2-dev liblqr-1-0-dev libltdl-dev libopenexr-dev libpng12-dev librsvg2-dev libtiff5-dev libwmf-dev libx11-dev libxext-dev libxml2-dev libxt-dev pkg-config libfftw3-double3 libfontconfig1 libjasper1 libjbig0 libjpeg8 liblcms2-2 liblqr-1-0 libltdl7 libtiff5 imagemagick-common ghostscript gsfonts mysql-server libmysqlclient-dev libreadline-dev llvm-3.2 clang-3.2 unzip llvm openjdk-6-jre balance

test -f compiler-latest.zip || curl -O http://dl.google.com/closure-compiler/compiler-latest.zip
(cd ~/.rbenv && git status) || git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
(cd ~/.rbenv/plugins/ruby-build && git status) || git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
grep rbenv ~/.profile || echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
grep eval ~/.profile || echo 'eval "$(rbenv init -)"' >> ~/.profile

. ~/.profile

(rbenv versions | grep 2.0.0-p247) || rbenv install 2.0.0-p247
rbenv global 2.0.0-p247

gem install rack
gem install rack-contrib
gem install sqlite3
gem install redcloth
gem install RedCloth
gem install daemons
gem install ruby2ruby
gem install uuidtools
gem install plist
gem install activerecord
gem install camping
gem install ruby-openid
