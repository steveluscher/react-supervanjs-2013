# Enable performance profiling?
window.PROFILE = window.getProfileSetting()

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
    console.time key
    startTimes[key] = perfNow()
  @timeEnd: (key) ->
    throw 'timeEnd() called without preceding call to time()' unless startTime = startTimes[key]
    (results[key] ||= []).push perfNow() - startTime
    console.timeEnd key

  @measure: (key, callback) ->
    Perf.time key
    out = callback()
    Perf.timeEnd key
    out

  @iqrMean: (key) ->
    # What are the results for this key?
    resultsForKey = results[key]
    return resultsForKey[0] if resultsForKey.length is 1
    # What values are at the boundary of the interquartile range?
    lowerBound = ss.quantile(resultsForKey, 0.25)
    upperBound = ss.quantile(resultsForKey, 0.75)
    # Throw out values outside the interquartile range
    middleFifty = []
    for result in resultsForKey
      middleFifty.push(result) if lowerBound < result and upperBound > result
    # Average the interquartile range
    arrayAverage middleFifty
  @min: (key) -> arrayMin results[key]
  @max: (key) -> arrayMax results[key]

  @results: ->
    ("#{key}: max: #{Perf.max(key).toFixed(2)}ms min: #{Perf.min(key).toFixed(2)}ms interquartile mean: #{Perf.iqrMean(key).toFixed(2)}ms" for key of results).join("\n")
