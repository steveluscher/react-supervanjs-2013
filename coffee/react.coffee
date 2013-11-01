# Given a data point, produce an object where the keys represent DOM element attributes
dataPointToAttributes = (dataPoint) ->
  style:
    backgroundColor: "rgba(0,255,0,#{dataPoint.brightness})"

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
    # Return data point elements, wrapped in a visualizer
    React.DOM.div @props, (React.DOM.div dataPointToAttributes(dataPoint) for dataPoint in @state.data)

# Create a visualizer
visualizer = new VisualizerComponent { id: 'visualizer', dataSource: (dataSource = new FunDataSource) }

# Render the visualizer
React.renderComponent visualizer, document.body

# Make the data source work as fast as possible
workIt = ->
  dataSource.doWork()
  setZeroTimeout workIt
workIt()
