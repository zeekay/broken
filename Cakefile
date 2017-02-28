require 'shortcake'

use 'cake-publish'
use 'cake-test'
use 'cake-version'

coffee      = require 'rollup-plugin-coffee-script'
commonjs    = require 'rollup-plugin-commonjs'
nodeResolve = require 'rollup-plugin-node-resolve'
rollup      = require 'rollup'

pkg         = require './package'

option '-g', '--grep [filter]', 'test filter'
option '-v', '--version [<newversion> | major | minor | patch | build]', 'new version'

task 'clean', 'clean project', ->
  exec 'rm -rf dist'

task 'build', 'build project', ->
  plugins = [
    coffee()
    nodeResolve
      browser: true
      extensions: ['.js', '.coffee']
      module:  true
    commonjs
      extensions: ['.js', '.coffee']
      sourceMap: true
  ]

  bundle = yield rollup.rollup
    entry:   'src/index.coffee'
    plugins:  plugins

  # Browser (single file)
  yield bundle.write
    dest:       pkg.name + '.js'
    format:     'iife'
    moduleName: 'Broken'

  # CommonJS
  yield bundle.write
    dest:       pkg.main
    format:     'cjs'
    sourceMap:  false

  # ES module bundle
  yield bundle.write
    dest:      pkg.module
    format:    'es'
    sourceMap: false

task 'build:min', 'build project', ->
  exec "uglifyjs #{pkg.name}.js --compress --mangle --lint=false > #{pkg.name}.min.js"
