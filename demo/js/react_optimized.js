var DataPoint, VisualizerComponent, dataSource, visualizer, markerButton, app;

// Create a React component for each data point in the visualization
DataPoint = React.createClass({
  shouldComponentUpdate: function(nextProps) {
    // If the brightness hasn't changed since last time, return false, blocking a needless update
    return this.props.brightness !== nextProps.brightness;
  },

  render: function() {
    // Render a simple div with a background color
    return React.DOM.div({ style: { backgroundColor: 'rgba(0,255,0,' + this.props.brightness + ')' } });
  }
});

// Create a React component for the visualizer
VisualizerComponent = React.createClass({
  getInitialState: function() {
    return { data: [] };
  },

  componentDidMount: function() {
    // Instantiate a data source
    this.dataSource = this.props.dataSource || new BoringDataSource();

    // Attach a handler to that data source, to be called whenever new data is available
    this.dataSource.onData(function(data) {
      if(PROFILE) Perf.time('setting state');
      this.replaceState({ data: data });
      if(PROFILE) Perf.timeEnd('setting state');
    }.bind(this));
  },

  render: function() {
    var data, dataPointComponents, dataPoint, dataPointComponent;

    // Get a list of data point components
    data = this.state.data;
    dataPointComponents = [];
    for(var i = data.length - 1; i >= 0; i--) {
      dataPoint = data[i];
      dataPointComponent = DataPoint({ brightness: dataPoint.brightness });

      dataPointComponents.push(dataPointComponent);
    }

    // Return data point components, wrapped in a visualizer
    return React.DOM.div(this.props, dataPointComponents);
  }
});

// Create a datasource
dataSource = new (getDataSource());

// Create a visualizer
visualizer = new VisualizerComponent({ id: 'visualizer', dataSource: dataSource });

// Create the marker button
markerButton = React.DOM.button({ className: 'mark', onClick: mark }, 'Mark');

// Create the app
app = React.DOM.body(null, [visualizer, markerButton]);

// Render the app
React.renderComponent(app, document.body, function() {
  // Make the data source work as fast as possible
  var workIt = function() {
    // Work!
    dataSource.doWork();

    // Force a synchronous reflow, then schedule another work package.
    // NOTE: This is preferable to using requestAnimationFrame, because RAF fires at funny times.
    if(PROFILE) Perf.time('redrawing');
    forceReflow();
    if(PROFILE) Perf.timeEnd('redrawing');

    // Schedule that next work package
    setZeroTimeout(workIt);
  }
  workIt();
});
