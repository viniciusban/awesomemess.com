.PHONY : help gulp_img runserver

export GEM_HOME := ${HOME}/.local/rubygems
export PATH := "${GEM_HOME}/bin:${PATH}"

help : Makefile
	@#help: Show this screen.
	@grep -o -e '^\w\+ \?:' -e '^	@#help: .\+' $< | sed -e 's/^	@#help: /\t/' -e 's/ :/:/'

gulp_img :
	@#help: Generate responsive images from the "./_img/posts/" directory
	./node_modules/gulp-cli/bin/gulp.js img

runserver :
	@#help: Run the local server
	bundle exec jekyll serve --watch
