require 'shortcake'

option '-g', '--grep [filter]', 'test filter'
option '-v', '--version [<newversion> | major | minor | patch | build]', 'new version'

task 'clean', 'clean project', (options) ->
  exec 'rm -rf lib'

task 'build', 'build project', (options) ->
  exec 'coffee -bcm -o lib/ src/'

task 'test', 'run tests', ->
  exec "NODE_ENV=test mocha
                      --colors
                      --reporter spec
                      --timeout 5000
                      --compilers coffee:coffee-script/register
                      --require postmortem/register
                      --require co-mocha
                      test"

task 'watch', 'watch for changes and recompile project', ->
  exec 'coffee -bc -m -w -o lib/ src/'

task 'publish', 'publish project', (options) ->
  exec.parallel '''
  git push
  git push --tags
  npm publish
  '''
