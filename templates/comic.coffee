
###
Default config settings for comic widget
###
localStorage["comic"] =
    background:     null    # The background colour, or dynamic if null
    rotation:       null    # The rotation for the pages when browsing
    page_display:   1       # Number of pages to display on screen
    manga:          false   # If the type can't be determined, browse in manga style
    preview:        null    # Preview as thumbnails, names or no preview

###
Keybindings:
Next        right arrow
Previous    left arrow
Fullscreen  f
Hide/Unhide h
###

console.info localStorage

###
class Router extends Backbone.Router

    routes:
        'test': 'route1'

    route1: ->
        console.info 'test route'
###

TestRouter = Backbone.Router.extend
  routes:
    '': 'index'
    'offers': 'offer'

  initialize: ->
    console.info 'initialize'
    @navigate ''

  index: ->
    console.info 'index'

  offer: ->
    console.info 'offer test'

window.router = new TestRouter


# Bind event to navigation to update breadcrumbs
window.router.bind('all', ( route, args ) -> console.info( route, args ) )

window.router.navigate 'offers'

Backbone.history.start()
