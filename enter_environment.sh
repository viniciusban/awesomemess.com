#
# Enter a new shell and source this file
#

export GEM_HOME=${HOME}/.local/rubygems
mkdir --parent $GEM_HOME
export PATH="${GEM_HOME}/bin:${PATH}"

alias gulp='node_modules/gulp-cli/bin/gulp.js'
