require 'shortcake'

use 'cake-bundle'
use 'cake-outdated'
use 'cake-publish'
use 'cake-test'
use 'cake-version'

option '-g', '--grep [filter]', 'test filter'
option '-v', '--version [<newversion> | major | minor | patch | build]', 'new version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'build', 'build project', ->
  # CommonJS and ES libs
  b = yield bundle
    entry: 'src/index.coffee'
    compilers:
      coffee: version: 1

  Promise.all [
    b.write formats: ['cjs','es']
    b.write
      format:    'web'
      external:  false
      sourceMap: false
  ]

task 'build:min', 'build project', ['build'], ->
  # Browser (single file)
  yield bundle.write
    entry:     'src/index.coffee'
    dest:      'broken.min.js'
    format:    'web'
    cache:     false
    external:  false
    minify:    true
    sourceMap: false
    compilers:
      coffee:
        version: 1
