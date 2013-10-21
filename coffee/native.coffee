# Cache some DOM elements
visualizerElement = document.getElementById('visualizer')
visualizerElementParent = visualizerElement.parentNode

# Create a mother grid point element; we'll clone it whenever we need a grid point
gridPointElementMother = document.createElement('div')

# Get a datasource
dataSource = new FunDataSource

# Attach a handler to that data source, to be called whenever new data is available
dataSource.onData (data) ->
  # Remove the visualizer from the DOM to prevent reflows
  visualizerElementParent.removeChild(visualizerElement)

  # …as we blow every DOM element away
  visualizerElement.innerHTML = ''

  for dataPoint in data
    # Construct a grid point DOM element by cloning the mother
    gridPointElement = gridPointElementMother.cloneNode()

    # Set its brightness
    gridPointElement.style.backgroundColor = "rgb(0,#{Math.round dataPoint.brightness * 255},0)"

    # Append this grid point to the visualizer
    visualizerElement.appendChild gridPointElement

  # Reattach the visualizer element
  visualizerElementParent.appendChild visualizerElement
