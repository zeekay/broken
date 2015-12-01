Promise = require 'zousan'

Promise.suppressUncaughtRejectionError = true

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

module.exports = Promise
