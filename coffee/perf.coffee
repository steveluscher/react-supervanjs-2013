window.Perf = class
  startTimes = {}
  results = {}

  # Polyfill for timers
  ((w) ->
    perfNow = undefined
    perfNowNames = ["now", "webkitNow", "msNow", "mozNow"]
    unless not w["performance"]
      i = 0

      while i < perfNowNames.length
        n = perfNowNames[i]
        unless not w["performance"][n]
          perfNow = ->
            w["performance"][n]()

          break
        ++i
    perfNow = Date.now  unless perfNow
    w.perfNow = perfNow
  ) window

  # Simple method to average an array of numbers
  arrayAverage = do ->
    sum = (a, b) -> a + b
    (array) -> array.reduce(sum) / array.length

  arrayMin = do ->
    compare = (a, b) -> if a < b then a else b
    (array) -> array.reduce(compare)

  arrayMax = do ->
    compare = (a, b) -> if a > b then a else b
    (array) -> array.reduce(compare)

  @time: (key) ->
    #console.time key
    #debugger if key is 'setting state'
    startTimes[key] = perfNow()
  @timeEnd: (key) ->
    throw 'timeEnd() called without preceding call to time()' unless startTime = startTimes[key]
    (results[key] ||= []).push perfNow() - startTime

    #debugger if key is 'setting state'
    #console.timeEnd key

  @measure: (key, callback) ->
    Perf.time key
    out = callback()
    Perf.timeEnd key
    out

  @average: (key) -> arrayAverage results[key]
  @min: (key) -> arrayMin results[key]
  @max: (key) -> arrayMax results[key]

  @results: ->
    ("#{key}: max: #{Perf.max(key).toFixed(2)}ms min: #{Perf.min(key).toFixed(2)}ms average: #{Perf.average(key).toFixed(2)}ms" for key of results).join("\n")
