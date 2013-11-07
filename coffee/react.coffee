DataPoint = React.createClass
  render: ->
    React.DOM.div (style: (backgroundColor: "rgba(0,255,0,#{@props.dataPoint.brightness})"))

# Create a React component for the visualizer
VisualizerComponent = React.createClass
  getInitialState: -> { data: [] }

  componentDidMount: ->
    # Attach a handler to that data source, to be called whenever new data is available
    @props.dataSource.onData (data) =>
      @setState { data: data }

  render: ->
    # Return data point elements, wrapped in a visualizer
    React.DOM.div @props, ((DataPoint (dataPoint: dataPoint)) for dataPoint in @state.data)

# Create a visualizer
visualizer = new VisualizerComponent { id: 'visualizer', dataSource: (dataSource = new (getDataSource())) }

# Create the marker button
markerButton = React.DOM.button { className: 'mark', onClick: mark }, 'Mark'

# Create the app
app = React.DOM.body null, [visualizer, markerButton]

# Render the app
React.renderComponent app, document.body, ->
  setInterval dataSource.doWork.bind(dataSource), 0

