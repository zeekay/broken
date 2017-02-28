var PromiseInspection;

var PromiseInspection$1 = PromiseInspection = (function() {
  function PromiseInspection(arg) {
    this.state = arg.state, this.value = arg.value, this.reason = arg.reason;
  }

  PromiseInspection.prototype.isFulfilled = function() {
    return this.state === 'fulfilled';
  };

  PromiseInspection.prototype.isRejected = function() {
    return this.state === 'rejected';
  };

  return PromiseInspection;

})();

var Promise$1;
var STATE_FULFILLED;
var STATE_PENDING;
var STATE_REJECTED;
var _undefined;
var _undefinedString;
var rejectClient;
var resolveClient;
var soon;

Promise$1 = function(func) {
  var me;
  if (func) {
    me = this;
    func(function(arg) {
      me.resolve(arg);
    }, function(arg) {
      me.reject(arg);
    });
  }
};

resolveClient = function(c, arg) {
  var err, yret;
  if (typeof c.y === 'function') {
    try {
      yret = c.y.call(_undefined, arg);
      c.p.resolve(yret);
    } catch (error1) {
      err = error1;
      c.p.reject(err);
    }
  } else {
    c.p.resolve(arg);
  }
};

rejectClient = function(c, reason) {
  var err, yret;
  if (typeof c.n === 'function') {
    try {
      yret = c.n.call(_undefined, reason);
      c.p.resolve(yret);
    } catch (error1) {
      err = error1;
      c.p.reject(err);
    }
  } else {
    c.p.reject(reason);
  }
};

STATE_PENDING = void 0;

STATE_FULFILLED = 'fulfilled';

STATE_REJECTED = 'rejected';

_undefined = void 0;

_undefinedString = 'undefined';

soon = (function() {
  var bufferSize, callQueue, cqYield, fq, fqStart;
  fq = [];
  fqStart = 0;
  bufferSize = 1024;
  cqYield = (function() {
    var dd, mo;
    if (typeof MutationObserver !== _undefinedString) {
      dd = document.createElement('div');
      mo = new MutationObserver(callQueue);
      mo.observe(dd, {
        attributes: true
      });
      return function() {
        dd.setAttribute('a', 0);
      };
    }
    if (typeof setImmediate !== _undefinedString) {
      return function() {
        setImmediate(callQueue);
      };
    }
    return function() {
      setTimeout(callQueue, 0);
    };
  })();
  callQueue = function() {
    var err;
    while (fq.length - fqStart) {
      try {
        fq[fqStart]();
      } catch (error1) {
        err = error1;
        if (global.console) {
          global.console.error(err);
        }
      }
      fq[fqStart++] = _undefined;
      if (fqStart === bufferSize) {
        fq.splice(0, bufferSize);
        fqStart = 0;
      }
    }
  };
  return function(fn) {
    fq.push(fn);
    if (fq.length - fqStart === 1) {
      cqYield();
    }
  };
})();

Promise$1.prototype.resolve = function(value) {
  var e, first, me, next;
  if (this.state !== STATE_PENDING) {
    return;
  }
  if (value === this) {
    return this.reject(new TypeError('Attempt to resolve promise with self'));
  }
  me = this;
  if (value && (typeof value === 'function' || typeof value === 'object')) {
    try {
      first = true;
      next = value.then;
      if (typeof next === 'function') {
        next.call(value, (function(ra) {
          if (first) {
            first = false;
            me.resolve(ra);
          }
        }), function(rr) {
          if (first) {
            first = false;
            me.reject(rr);
          }
        });
        return;
      }
    } catch (error1) {
      e = error1;
      if (first) {
        this.reject(e);
      }
      return;
    }
  }
  this.state = STATE_FULFILLED;
  this.v = value;
  if (me.c) {
    soon(function() {
      var l, n;
      n = 0;
      l = me.c.length;
      while (n < l) {
        resolveClient(me.c[n], value);
        n++;
      }
    });
  }
};

Promise$1.prototype.reject = function(reason) {
  var clients;
  if (this.state !== STATE_PENDING) {
    return;
  }
  this.state = STATE_REJECTED;
  this.v = reason;
  clients = this.c;
  if (clients) {
    soon(function() {
      var l, n;
      n = 0;
      l = clients.length;
      while (n < l) {
        rejectClient(clients[n], reason);
        n++;
      }
    });
  } else if (!Promise$1.suppressUncaughtRejectionError && global.console) {
    global.console.log('Broken Promise! Please catch rejections: ', reason, reason ? reason.stack : null);
  }
};

Promise$1.prototype.then = function(onF, onR) {
  var a, client, p, s;
  p = new Promise$1;
  client = {
    y: onF,
    n: onR,
    p: p
  };
  if (this.state === STATE_PENDING) {
    if (this.c) {
      this.c.push(client);
    } else {
      this.c = [client];
    }
  } else {
    s = this.state;
    a = this.v;
    soon(function() {
      if (s === STATE_FULFILLED) {
        resolveClient(client, a);
      } else {
        rejectClient(client, a);
      }
    });
  }
  return p;
};

Promise$1.prototype["catch"] = function(cfn) {
  return this.then(null, cfn);
};

Promise$1.prototype["finally"] = function(cfn) {
  return this.then(cfn, cfn);
};

Promise$1.prototype.timeout = function(ms, timeoutMsg) {
  var me;
  timeoutMsg = timeoutMsg || 'Timeout';
  me = this;
  return new Promise$1(function(resolve, reject) {
    setTimeout((function() {
      reject(Error(timeoutMsg));
    }), ms);
    me.then((function(v) {
      resolve(v);
    }), function(er) {
      reject(er);
    });
  });
};

Promise$1.prototype.callback = function(cb) {
  if (typeof cb === 'function') {
    this.then(function(value) {
      return cb(null, value);
    });
    this["catch"](function(error) {
      return cb(error, null);
    });
  }
  return this;
};

Promise$1.resolve = function(val) {
  var z;
  z = new Promise$1;
  z.resolve(val);
  return z;
};

Promise$1.reject = function(err) {
  var z;
  z = new Promise$1;
  z.reject(err);
  return z;
};

Promise$1.all = function(pa) {
  var rc, results, retP, rp, x;
  results = [];
  rc = 0;
  retP = new Promise$1;
  rp = function(p, i) {
    if (!p || typeof p.then !== 'function') {
      p = Promise$1.resolve(p);
    }
    p.then((function(yv) {
      results[i] = yv;
      rc++;
      if (rc === pa.length) {
        retP.resolve(results);
      }
    }), function(nv) {
      retP.reject(nv);
    });
  };
  x = 0;
  while (x < pa.length) {
    rp(pa[x], x);
    x++;
  }
  if (!pa.length) {
    retP.resolve(results);
  }
  return retP;
};

Promise$1.reflect = function(promise) {
  return new Promise$1(function(resolve, reject) {
    return promise.then(function(value) {
      return resolve(new PromiseInspection$1({
        state: 'fulfilled',
        value: value
      }));
    })["catch"](function(err) {
      return resolve(new PromiseInspection$1({
        state: 'rejected',
        reason: err
      }));
    });
  });
};

Promise$1.settle = function(promises) {
  return Promise$1.all(promises.map(Promise$1.reflect));
};

var Promise$2 = Promise$1;

export default Promise$2;
