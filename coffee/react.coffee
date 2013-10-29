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
    React.DOM.div @props, (React.DOM.div { style: { backgroundColor: "rgba(0, 255, 0, #{dataPoint.brightness})" } }, dataPoint.brightness * 255 for dataPoint, i in @state.data)

# Create a visualizer
visualizer = new VisualizerComponent { id: 'visualizer', dataSource: (dataSource = new FunDataSource) }

# Render the visualizer
React.renderComponent visualizer, document.body

# Make the data source work every frame
workIt = ->
  dataSource.doWork()
  setTimeout workIt, 0
workIt()
