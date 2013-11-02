# Cache some DOM elements
visualizerElement = document.getElementById('visualizer')
visualizerElementParent = visualizerElement.parentNode

# Create a mother grid point element; we'll clone it whenever we need a grid point
gridPointElementMother = document.createElement('div')

# Get a datasource
dataSource = new (getDataSource())

# Attach a handler to that data source, to be called whenever new data is available
dataSource.onData (data) ->
  Perf.time 'redrawing DOM'

  # Remove the visualizer from the DOM to prevent reflows
  visualizerElementParent.removeChild(visualizerElement)

  # …as we blow every DOM element away
  visualizerElement.innerHTML = ''

  for dataPoint in data
    # Construct a grid point DOM element by cloning the mother
    gridPointElement = gridPointElementMother.cloneNode()

    # Set its brightness
    gridPointElement.style.backgroundColor = "rgba(0, 255, 0, #{dataPoint.brightness})"

    # Append this grid point to the visualizer
    visualizerElement.appendChild gridPointElement

  # Reattach the visualizer element
  visualizerElementParent.appendChild visualizerElement

  Perf.timeEnd 'redrawing DOM'

# Make the data source work as fast as possible
workIt = ->
  # Work!
  dataSource.doWork()

  # Force a synchronous reflow, then schedule another work package.
  # NOTE: This is preferable to using requestAnimationFrame, because RAF fires at funny times.
  Perf.time 'redrawing' if PROFILE
  forceReflow()
  Perf.timeEnd 'redrawing' if PROFILE

  # Schedule that next work package
  setZeroTimeout workIt
workIt()
