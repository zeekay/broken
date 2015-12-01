Promise = require '../lib'

describe 'Promise.reflect', ->
  it 'should wrap promises and always resolve to PromiseInspections', ->
    pi = yield Promise.reflect Promise.resolve 1
    pi.value.should.be.eq 1

describe 'Promise.settle', ->
  it 'should resolve to array of PromiseInspections', ->
    pis = yield Promise.settle [Promise.resolve(1), Promise.reject(2), Promise.resolve(3)]
    pis[0].value.should.be.eq 1
    pis[1].reason.should.be.eq 2
    pis[2].value.should.be.eq 3

