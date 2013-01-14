
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


class ConfigView extends Backbone.View
  initialize: ->
    console.info 'ConfigView.initialize'


class PreviewView extends Backbone.View
  tagName: 'nav'

  initialize: ->
    console.info 'PreviewView.initialize'
    $(@el).addClass 'span1 preview'

  render: ->
    console.info 'PreviewView.render'
    $(@el).html '<ol><li><img class="thumbnail" src="/static/img/wild-cats/v01/c01/cover.jpg" /></a></li><li><img class="thumbnail" src="/static/img/wild-cats/v01/c01/003.png" /></a></li><li><img class="thumbnail" src="/static/img/wild-cats/v01/c01/004.png" /></li></ol>'


class MainView extends Backbone.View
  initialize: ->
    console.info 'MainView.initialize'
    _.bindAll @
    $(@el).addClass 'span11 main'
    @render()

  render: ->
    console.info 'MainView.render'
    $(@el).html '<img style="height: 100%" class="main" src="/static/img/wild-cats/v01/c01/cover.jpg"/><a href="#next" class="next">next</a><a href="#prev" class="prev">prev</a>'


class ComicView extends Backbone.View
  events:
    'click .thumbnail': 'goto'
    'click .next': 'next'
    'click .prev': 'prev'
    'keypress .main': 'keypress'

  el: $ 'body'

  initialize: ->
    _.bindAll @
    $(@el).addClass 'row-fluid'
    @views =
      main: new MainView
      preview: new PreviewView
    @render()

  render: ->
    console.info 'ComicView.render'
    $(@el).html @views.preview.el
    $(@el).append @views.main.el
    @views.preview.render()
    @views.main.render()

  goto: (event) ->
    console.info 'MainView.goto'
    event.preventDefault()
    $(@el).find( '.main' ).attr( 'src', $(event.currentTarget).attr( 'src' ) )

  next: (event) ->
    console.info 'MainView.next'
    event.preventDefault()

  prev: (event) ->
    console.info 'MainView.prev'
    event.preventDefault()

  keypress: (event) ->
    console.info event


class Router extends Backbone.Router
  routes:
    '': 'index'

  initialize: ->
    console.info 'initialize'

  index: ->
    console.info 'index'
    new ComicView


router = new Router

# Bind event to navigation to update breadcrumbs
router.bind('all', ( route, args ) -> console.info( route, args ) )

Backbone.history.start()

