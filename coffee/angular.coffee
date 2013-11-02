angular.module('visualizerDemo', [])

  .directive 'visualizer', ->
    restrict: 'E' # Only applies to tag names
    controller: ($scope, $interval) ->
      # Instantiate a data source
      window.dataSource = new (getDataSource()) or new BoringDataSource

      # Provide a method that generates styles given a data point
      $scope.styleFromDataPoint = (dataPoint) -> backgroundColor: "rgba(0,255,0,#{dataPoint.brightness})"

      # Attach a handler to that data source, to be called whenever new data is available
      dataSource.onData (data) ->
        # Set the data
        Perf.time 'setting data' if PROFILE
        $scope.data = data
        Perf.timeEnd 'setting data' if PROFILE

      $interval dataSource.doWork, 0
