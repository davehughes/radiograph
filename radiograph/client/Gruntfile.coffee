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

    watch:
      options:
        livereload: true

      coffee:
        files: 'coffee/**/*.coffee'
        tasks: ['coffee']

      less:
        files: 'less/**/*.less'
        tasks: ['less']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('default', ['coffee', 'less'])
