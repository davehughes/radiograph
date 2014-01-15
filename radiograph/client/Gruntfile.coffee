module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files: [{
          '../static/gen/js/radiograph.js': ['coffee/**/*.coffee'],
        }]

    less:
      development:
        options:
          dumpLineNumbers: true
        files:
          '../static/gen/css/radiograph.css': 'less/radiograph.less'

    #   production:
    #     options:
    #       yuicompress: true
    #     files:
    #       '../static/gen/css/style.css': 'less/style.less'

    dust:
      defaults:
        files: [{
          expand: true,
          cwd: 'dust/'
          src: ['**/*.dust']
          dest: '../static/gen/js/templates.js'
          rename: (dest, src) -> dest
          }]
        options:
          relative: true
          runtime: false
          amd: false

    # uglify:
    #   build:
    #     src: '../static/gen/js/*.js'
    #     dest: '../static/gen/js/all.min.js'

    # requirejs:
    #   compile:
    #     options:
    #       baseUrl: '../static/gen/js
    #       mainConfigFile: 

    watch:
      options:
        livereload: true

      coffee:
        files: 'coffee/**/*.coffee'
        tasks: ['coffee']

      less:
        files: 'less/**/*.less'
        tasks: ['less']

      dust:
        files: 'dust/**/*.dust'
        tasks: ['dust']

      handlebars:
        files: 'handlebars/**/*.hbs'
        tasks: ['handlebars']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-handlebars')
  grunt.loadNpmTasks('grunt-dust')

  grunt.registerTask('default', ['coffee', 'less'])
