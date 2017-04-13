use 'sake-bundle'
use 'sake-outdated'
use 'sake-publish'
use 'sake-test'
use 'sake-version'

task 'clean', 'clean project', ->
  exec 'rm -rf lib'

task 'build', 'build project', ->
  b = yield bundle
    entry: 'src/index.coffee'
    compilers:
      coffee: version: 1

  Promise.all [
    # CommonJS and ES libs
    b.write formats: ['cjs','es']
    # All-contained web browser package
    b.write
      format:    'web'
      external:  false
      sourceMap: false
  ]

task 'build:min', 'build project', ['build'], ->
  exec 'uglifyjs broken.js -o broken.min.js'
