# Create a React component for each data point in the visualization
DataPoint = React.createClass
  shouldComponentUpdate: (prevProps) ->
    # If the brightness hasn't changed since last time, return false, blocking a needless update
    prevProps.brightness isnt @props.brightness

  render: ->
    # Render a simple div with a background color
    React.DOM.div
      style:
        backgroundColor: "rgba(0,255,0,#{@props.brightness})"

# Create a React component for the visualizer
VisualizerComponent = React.createClass
  getInitialState: -> { data: [] }

  componentDidMount: ->
    # Instantiate a data source
    @dataSource = @props.dataSource or new BoringDataSource

    # Attach a handler to that data source, to be called whenever new data is available
    @dataSource.onData (data) =>
      Perf.time 'setting state' if PROFILE
      @replaceState { data: data }
      Perf.timeEnd 'setting state' if PROFILE

  render: ->
    # Return data point components, wrapped in a visualizer
    React.DOM.div @props, (DataPoint(brightness: dataPoint.brightness) for dataPoint in @state.data)

# Create a visualizer
visualizer = new VisualizerComponent { id: 'visualizer', dataSource: (dataSource = new (getDataSource())) }

# Create the marker button
markerButton = React.DOM.button { className: 'mark', onClick: mark }, 'Mark'

# Create the app
app = React.DOM.body null, [visualizer, markerButton]

# Render the app
React.renderComponent app, document.body, ->
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
