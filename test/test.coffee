Promise = require '../'

describe 'Promise.reflect', ->
  it 'should wrap promises and always resolve to PromiseInspections', ->
    p = yield Promise.reflect Promise.resolve 1
    p.value.should.be.eq 1

describe 'Promise.settle', ->
  it 'should resolve to array of PromiseInspections', ->
    ps = yield Promise.settle [Promise.resolve(1), Promise.reject(2), Promise.resolve(3)]
    ps[0].value.should.be.eq 1
    ps[1].reason.should.be.eq 2
    ps[2].value.should.be.eq 3

describe 'Promise::callback', ->
  it 'should tie a callback to a promise', ->
    p = Promise.resolve(1)
    yield p.callback (err, value) -> value.should.eq 1

  it 'should ignore missing callbacks', ->
    value = yield Promise.resolve(1).callback(null)
    value.should.eq 1

    try
      value = yield Promise.reject(2).callback(null)
    catch err
    err.should.eq 2
