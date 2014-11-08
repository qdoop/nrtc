/**
 * Created by qdoop on 9/25/14.
 */
var gulp   = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
// var imagemin = require('gulp-imagemin');
// var sourcemaps = require('gulp-sourcemaps');
//var del = require('del');

var bowerdir='./bower_components/';
var paths = {
	scripts: [

		bowerdir + 'jquery/dist/jquery.js',


		'web/*.js',

		'!client/external/**/*.coffee'
	],

	coffee:[
		'web/*.coffee',
	],

	styles:[

	],

	copies:[
		bowerdir + 'jquery/dist/jquery.min.map'
	],

	images:[
		'web/img/**/*'
	],

	pages:[
		'web/**/*.html'
	]
};

// Not all tasks need to use streams
// A gulpfile is just another node program and you can use all packages available on npm
gulp.task('clean', function(cb) {
	//	del(['build'], cb);
	cb();
});


gulp.task('scripts', ['clean'], function() {
	// Minify and copy all JavaScript (except vendor scripts)
	// with sourcemaps all the way down
	return gulp.src(paths.scripts)
		// .pipe(sourcemaps.init())
		// .pipe(uglify())
		.pipe(concat('build0.js'))
		// .pipe(sourcemaps.write())
		.pipe(gulp.dest('out'));
});

gulp.task('coffee', ['clean'], function() {
	return gulp.src(paths.coffee)
		// .pipe(coffee({bare:true})) //no outter wrap function
		.pipe(coffee())
		.pipe(concat('build1.js'))
		.pipe(gulp.dest('out'));
});

gulp.task('styles', function() {
	return gulp.src(paths.styles)
		.pipe(concat('build.css'))
		.pipe(gulp.dest('out'));
});


gulp.task('copies', function() {
	return gulp.src(paths.copies)
		.pipe(gulp.dest('out'));
});


gulp.task('images', ['clean'], function() {
	return gulp.src(paths.images)
		// .pipe(imagemin({optimizationLevel: 5}))
		.pipe(gulp.dest('out/img'));
});

gulp.task('pages', ['clean'], function() {
	return gulp.src(paths.pages)
		.pipe(gulp.dest('out'));
});

// Rerun the task when a file changes
gulp.task('watch', function() {
	gulp.watch(paths.coffee,  ['coffee']  );
	gulp.watch(paths.scripts, ['scripts'] );
	gulp.watch(paths.styles,  ['styles']  );
	gulp.watch(paths.copies,  ['copies']  );
	gulp.watch(paths.images,  ['images']  );
	gulp.watch(paths.pages,   ['pages']   );
});

// The default task (called when you run `gulp` from cli)
gulp.task('default',  [         'coffee', 'scripts', 'styles', 'copies','images','pages']);
gulp.task('default0', ['watch', 'coffee', 'scripts', 'styles', 'copies','images','pages']);
