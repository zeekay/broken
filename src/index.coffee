Promise = require 'zousan'

Promise.suppressUncaughtRejectionError = false

class PromiseInspection
  constructor: ({@state, @value, @reason}) ->

  isFulfilled: ->
    @state is 'fulfilled'

  isRejected: ->
    @state is 'rejected'

Promise.reflect = (promise) ->
  new Promise (resolve, reject) ->
    promise
      .then (value) ->
        resolve new PromiseInspection
          state: 'fulfilled'
          value: value
      .catch (err) ->
        resolve new PromiseInspection
          state: 'rejected'
          reason: err

Promise.settle = (promises) ->
  Promise.all promises.map Promise.reflect

Promise::callback = (cb) ->
  if typeof cb is 'function'
    @then  (value) -> cb null, value
    @catch (error) -> cb error, null
  @

module.exports = Promise
