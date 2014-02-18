module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files: 
          'js/server.js': 'coffee/server.coffee'
          'js/run.js': 'coffee/run.coffee'

    watch:
      options:
        livereload: true

      coffee:
        files: 'coffee/**/*.coffee'
        tasks: ['coffee']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('default', ['coffee'])
