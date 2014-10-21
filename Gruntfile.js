
module.exports = function (grunt) {

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-jsonlint');

  grunt.initConfig({
    watch: {
      files: [
        'lib/**/*',
        'assets/**/*',
        'scripts/**/*',
        'test/**/*',
      ],
      tasks: [
        'jsonlint:assets',
        'shell:assets',
        'mochaTest'
      ]
    },
    jsonlint: {
      assets: {
        src: [
          'assets/**/*.json'
        ]
      }
    },
    shell: {
      assets: {
        command: 'coffee scripts/buildAssets.coffee'
      }
    },
    mochaTest: {
      test: {
        options: {
          reporter: 'spec',
          require: 'coffee-script/register'
        },
        src: [
          'test/**/*.coffee'
        ]
      }
    }
  })

  grunt.registerTask('default', [
    'jsonlint:assets',
    'shell:assets',
    'mochaTest',
    'watch'
  ]);

}
