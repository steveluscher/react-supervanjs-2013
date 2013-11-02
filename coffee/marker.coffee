window.mark = ->
  # Get all of the grid point elements in the DOM
  gridPointElements = document.getElementById('visualizer').childNodes

  # Mark them all red
  gridPointElement.style.backgroundColor = 'red' for gridPointElement in gridPointElements
