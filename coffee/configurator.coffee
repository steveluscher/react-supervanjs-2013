DEFAULT_GRID_SIZE = 128
DEFAULT_DATA_SOURCE_TYPE = 'Boring'

# Configure the app by passing the querystring "?{data-source-type}-{grid-size}"
[dataSourceType, gridSize] = window.location.search.replace(/^\?/, '').split('-')

# Apply defaults
gridSize ||= DEFAULT_GRID_SIZE
dataSourceType ||= DEFAULT_DATA_SOURCE_TYPE

# Expose some getters
window.getDataSource = ->
  return unless className = dataSourceType?.toLowerCase()
  window["#{className.charAt(0).toUpperCase()}#{className.slice(1)}DataSource"]
window.getGridSize = -> gridSize

# Generate some CSS, dynamically, depending on how large the grid is
css = """
#visualizer div {
  width: #{100 / gridSize}%;
  height: #{100 / gridSize}%;
  float: left;
}
#visualizer div:nth-child(#{gridSize}n + 1) {
  clear: left;
}
"""

# Write the styles to the page
head = document.getElementsByTagName('head')[0]
style = document.createElement('style')
style.type = 'text/css'
if style.styleSheet then style.styleSheet.cssText = css
else style.appendChild(document.createTextNode(css))
head.appendChild(style)
