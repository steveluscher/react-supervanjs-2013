var dataPointToAttributes, VisualizerComponent, dataSource, visualizer, markerButton, app;

// Given a data point, produce an object where the keys represent DOM element attributes
dataPointToAttributes = function(dataPoint) {
  return {
    style: {
      backgroundColor: 'rgba(0,255,0,' + dataPoint.brightness + ')'
    }
  };
};

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
    var data, dataPointComponents, dataPoint, dataPointAttributes, dataPointComponent;

    // Get a list of data point components
    data = this.state.data;
    dataPointComponents = [];
    for(var i = data.length - 1; i >= 0; i--) {
      dataPoint = data[i];
      dataPointAttributes = dataPointToAttributes(dataPoint);
      dataPointComponent = React.DOM.div(dataPointAttributes);

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
