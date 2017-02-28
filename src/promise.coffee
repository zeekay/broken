# Largely copied from Zousan: https://github.com/bluejava/zousan
import PromiseInspection from './promise-inspection'
import soon from './soon'

# Let the obfiscator compress these down by assigning them to variables
_undefined       = undefined
_undefinedString = 'undefined'

# These are the three possible states (PENDING remains undefined - as intended)
# a promise can be in.  The state is stored in this.state as read-only
STATE_PENDING   = _undefined
STATE_FULFILLED = 'fulfilled'
STATE_REJECTED  = 'rejected'

Promise = (fn) ->
  if fn
    fn (arg) =>
      @resolve arg
    , (arg) =>
      @reject arg       # the reject function bound to this context
  return

resolveClient = (c, arg) ->
  if typeof c.y == 'function'
    try
      yret = c.y.call(_undefined, arg)
      c.p.resolve yret
    catch err
      c.p.reject err
  else
    # pass this along...
    c.p.resolve arg
  return

rejectClient = (c, reason) ->
  if typeof c.n == 'function'
    try
      yret = c.n.call(_undefined, reason)
      c.p.resolve yret
    catch err
      c.p.reject err
  else
    # pass this along...
    c.p.reject reason
  return

Promise::resolve = (value) ->
  if @state != STATE_PENDING
    return
  if value == this
    return @reject(new TypeError('Attempt to resolve promise with self'))
  me = this
  # preserve this
  if value and (typeof value == 'function' or typeof value == 'object')
    try
      first = true
      # first time through?
      next = value.then
      if typeof next == 'function'
        # and call the value.then (which is now in "then") with value as the context and the resolve/reject functions per thenable spec
        next.call value, ((ra) ->
          if first
            first = false
            me.resolve ra
          return
        ), (rr) ->
          if first
            first = false
            me.reject rr
          return
        return
    catch e
      if first
        @reject e
      return
  @state = STATE_FULFILLED
  @v = value
  if me.c
    soon ->
      n = 0
      l = me.c.length
      while n < l
        resolveClient me.c[n], value
        n++
      return
  return

Promise::reject = (reason) ->
  if @state != STATE_PENDING
    return
  @state = STATE_REJECTED
  @v = reason
  clients = @c
  if clients
    soon ->
      n = 0
      l = clients.length
      while n < l
        rejectClient clients[n], reason
        n++
      return
  else if !Promise.suppressUncaughtRejectionError and global.console
    global.console.log 'Broken Promise! Please catch rejections: ', reason, if reason then reason.stack else null
  return

Promise::then = (onF, onR) ->
  p = new Promise

  client =
    y: onF
    n: onR
    p: p

  if @state == STATE_PENDING
    # we are pending, so client must wait - so push client to end of this.c array (create if necessary for efficiency)
    if @c
      @c.push client
    else
      @c = [ client ]
  else
    s = @state
    a = @v
    soon ->
      # we are not pending, so yield script and resolve/reject as needed
      if s == STATE_FULFILLED
        resolveClient client, a
      else
        rejectClient client, a
      return
  p

Promise::catch = (cfn) ->
  @then null, cfn

Promise::finally = (cfn) ->
  @then cfn, cfn

Promise::timeout = (ms, timeoutMsg) ->
  timeoutMsg = timeoutMsg or 'Timeout'
  me = this

  new Promise (resolve, reject) ->
    setTimeout (->
      reject Error(timeoutMsg)
      # This will fail silently if promise already resolved or rejected
      return
    ), ms
    me.then ((v) ->
      resolve v
      return
    ), (er) ->
      reject er
      return
    # This will fail silently if promise already timed out
    return

Promise::callback = (cb) ->
  if typeof cb is 'function'
    @then  (value) -> cb null, value
    @catch (error) -> cb error, null
  @

Promise.resolve = (val) ->
  z = new Promise
  z.resolve val
  z

Promise.reject = (err) ->
  z = new Promise
  z.reject err
  z

Promise.all = (ps) ->
  # Sesults and resolved count
  results = []
  rc      = 0
  retP    = new Promise()

  resolvePromise = (p, i) ->
    if !p or typeof p.then != 'function'
      p = Promise.resolve(p)

    p.then (yv) ->
      results[i] = yv
      rc++
      if rc == ps.length
        retP.resolve results
      return

    , (nv) ->
      retP.reject nv
      return

    return

  resolvePromise p, i for p, i in ps

  # For zero length arrays, resolve immediately
  if !ps.length
    retP.resolve results

  retP

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

Promise.soon = soon

export default Promise
