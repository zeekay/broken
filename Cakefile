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
  yield bundle.write
    entry:   'src/index.coffee'
    formats: ['cjs','es']

  # Browser (single file)
  yield bundle.write
    entry:     'src/index.coffee'
    format:    'web'
    external:  false
    sourceMap: false

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
