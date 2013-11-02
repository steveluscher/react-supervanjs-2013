# Minimal polyfill for AudioContext
window.AudioContext ||= window.webkitAudioContext or
                        window.mozAudioContext

# Minimal polyfill for requestAnimationFrame
window.requestAnimationFrame ||= window.webkitRequestAnimationFrame or
                                 window.mozRequestAnimationFrame

# Minimal polyfill for getUserMedia
navigator.getUserMedia ||= navigator.webkitGetUserMedia or
                           navigator.mozGetUserMedia or
                           navigator.msGetUserMedia

# Zero-timeout implementation with window.postMessage()
do ->
  # Like setTimeout, but only takes a function argument.  There's
  # no time argument (always zero) and no arguments (you have to
  # use a closure).
  setZeroTimeout = (fn) ->
    timeouts.push fn
    window.postMessage messageName, "*"

  handleMessage = (event) ->
    if event.source is window and event.data is messageName
      event.stopPropagation()
      if timeouts.length > 0
        fn = timeouts.shift()
        fn()

  timeouts = []
  messageName = "zero-timeout-message"

  window.addEventListener "message", handleMessage, true

  # Add the one thing we want added to the window object.
  window.setZeroTimeout = setZeroTimeout

# Trick to pause the Javascript interpreter until the next reflow has happened
window.forceReflow = -> document.body.offsetHeight
