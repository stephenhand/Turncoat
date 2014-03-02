###
Copyright (c) 2012, Benjamin Dumke-von der Ehe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
###

#
# Mutex.lock(key, lockAquiredCallback)
#


define(["uuid"], (UUID)->
  now = ->
    new Date().getTime()

  getter = (lskey) ->
    ()->
      value = localStorage[lskey]
      return null unless value
      splitted = value.split(/\|/)
      return null if parseInt(splitted[1]) < now()
      splitted[0]

  _mutexTransaction = (key, callback, synchronous) ->

    criticalSection = ()->
      try
        callback()
      finally
        localStorage.removeItem yKey

    xKey = key + "__MUTEX_x"
    yKey = key + "__MUTEX_y"
    getY = getter(yKey)
    localStorage[xKey] = myId
    if getY()
      unless synchronous
        setTimeout (()->
          _mutexTransaction key, callback
        ), 0
      return false
    localStorage[yKey] = myId + "|" + (now() + 40)
    if localStorage[xKey] isnt myId
      unless synchronous
        setTimeout (()->
          if getY() isnt myId
            setTimeout (()->
              _mutexTransaction key, callback
            ), 0
          else
            criticalSection()
        ), 50
      false
    else
      criticalSection()
      true

  lockImpl = (key, callback, maxDuration, synchronous) ->
    unhandledError = null
    keyParam = key
    if key.key?
      callback = key.criticalSection
      maxDuration = key.maxDuration
      success = key.success
      error = key.error
      key = key.key

    restart = ()->
      setTimeout (()->
        lockImpl keyParam, callback, maxDuration
      ), 10

    mutexAquired = ()->
      try
        callback()
      catch e
        unhandledError = e
      finally
        _mutexTransaction(key, ()->
          if localStorage[mutexKey] isnt mutexValue
            throw key + " was locked by a different process while I held the lock"
          localStorage.removeItem mutexKey
        )
        if unhandledError?
          if error? then error(unhandledError)
        else
          if success then success()

    maxDuration = maxDuration or 5000
    mutexKey = key + "__MUTEX"
    getMutex = getter(mutexKey)
    mutexValue = myId + ":" + UUID() + "|" + (now() + maxDuration)

    if getMutex()
      restart()  unless synchronous
      return false

    aquiredSynchronously = _mutexTransaction(
      key,
      ()->
        if getMutex()
          restart()  unless synchronous
          return false
        localStorage[mutexKey] = mutexValue
        setTimeout(mutexAquired, 0) unless synchronous
      ,synchronous
    )

    if synchronous and aquiredSynchronously
      mutexAquired()
      return true

    return false

  myId = now() + ":" + UUID()

  Mutex =
    lock: (key, callback, maxDuration) ->
      lockImpl key, callback, maxDuration, false

    trySyncLock: (key, callback, maxDuration) ->
      lockImpl key, callback, maxDuration, true

  Mutex

)

