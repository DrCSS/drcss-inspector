gulp = require('gulp')
coffee = require('gulp-coffee')
gutil = require('gulp-util')
plumber = require('gulp-plumber')
jsdoc = require('gulp-jsdoc')

errorLog = (err) ->
  console.log(err.code)

gulp.task 'default', ['coffee']

gulp.task 'coffee', ->
  gulp.src('src/**/*.coffee')
    .pipe(plumber())
    .pipe(coffee())
    .pipe(gulp.dest('./'))

gulp.task 'doc', ->
  gulp.src('./lib/**/*.js')
    .pipe(jsdoc('./doc'))

gulp.task 'watch', ->
  gulp.watch 'src/**/*.coffee', ['coffee']