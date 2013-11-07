# Given a data point, produce an object where the keys represent DOM element attributes
dataPointToAttributes = (dataPoint) ->
  style:
    backgroundColor: "rgba(0,255,0,#{dataPoint.brightness})"

# Create a React component for the visualizer
VisualizerComponent = React.createClass
  getInitialState: -> { data: [] }

  componentDidMount: ->
    # Attach a handler to that data source, to be called whenever new data is available
    @props.dataSource.onData (data) =>
      @setState { data: data }

  render: ->
    # Return data point elements, wrapped in a visualizer
    React.DOM.div @props, (React.DOM.div dataPointToAttributes(dataPoint) for dataPoint in @state.data)

# Create a visualizer
visualizer = new VisualizerComponent { id: 'visualizer', dataSource: (dataSource = new (getDataSource())) }

# Create the marker button
markerButton = React.DOM.button { className: 'mark', onClick: mark }, 'Mark'

# Create the app
app = React.DOM.body null, [visualizer, markerButton]

# Render the app
React.renderComponent app, document.body, ->
  setInterval dataSource.doWork.bind(dataSource), 0

