module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files: 
          'server.js': 'src/server.coffee'

    # uglify:
    #   build:
    #     src: '../static/gen/js/*.js'
    #     dest: '../static/gen/js/all.min.js'

    watch:
      options:
        livereload: true

      coffee:
        files: 'src/**/*.coffee'
        tasks: ['coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('default', ['coffee'])
