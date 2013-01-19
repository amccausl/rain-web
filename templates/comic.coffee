
###
Keybindings:
Next        right arrow
Previous    left arrow
Fullscreen  f
Hide/Unhide h
###

### Config ###

localStorage['comic'] = JSON.stringify (
    background:     null    # The background colour, or dynamic if null
    rotation:       0       # The rotation for the pages when browsing
    page_display:   1       # Number of pages to display on screen
    manga:          false   # If the type can't be determined, browse in manga style
    preview:        null    # Preview as thumbnails, names or no preview
)

config = JSON.parse( localStorage['comic'] )

### Models ###

class Comic extends Backbone.Model
  initialize: ( id ) ->
    console.info 'comic initialized', id

  url: ->
    return "/static/content/demo/#{@id}.json"

### Views ###

class ConfigView extends Backbone.View
  initialize: ->
    console.info 'ConfigView.initialize'
    _.bindAll @


class PreviewView extends Backbone.View
  tagName: 'nav'

  initialize: ->
    console.info 'PreviewView.initialize'
    _.bindAll @
    $(@el).addClass 'span1 preview'

  render: ->
    console.info 'PreviewView.render'

    if( @model.get('pages') != undefined )
        pages = @model.get('pages')
        html = for src in pages
          "<li><img class=\"thumbnail\" src=\"#{src}\" /></a></li>"

    $(@el).html "<ol>#{html}</ol>"


class MainView extends Backbone.View
  initialize: ->
    console.info 'MainView.initialize'
    _.bindAll @
    $(@el).addClass 'span11 main'

  render: ->
    console.info 'MainView.render'
    if( @image )
        # Create image element
        # Determine size of original image
        # Create transformation matrix based off size of the container and image to fit
        $(@el).html "<img class=\"main\" src=\"#{@image}\"/><a href=\"#next\" class=\"next\">next</a><a href=\"#prev\" class=\"prev\">prev</a>"

  set_image: ( src ) ->
    console.info 'MainView.set_image'
    @image = src
    @render()


class ComicView extends Backbone.View
  events:
    'click .thumbnail': 'goto'
    'click .next': 'next'
    'click .prev': 'prev'
    'keypress .main': 'keypress'

  el: $ 'body'

  initialize: ->
    console.info 'ComicView.initialize'
    _.bindAll @
    @model.bind 'change', @render
    $(@el).addClass 'row-fluid'
    @views =
      main: new MainView( model: @model )
      preview: new PreviewView( model: @model )

    #$(window).on('orientationchange', ( event ) => console.info( 'orientation', @render() ) )
    $(window).bind 'resize.app', @render

  remove: ->
    $(window).unbind 'resize.app'
    super()

  render: ->
    console.info( 'ComicView.render', $(window).width(), $(window).height() )
    $(@el).html @views.preview.el
    $(@el).append @views.main.el
    @views.preview.render()
    @views.main.render()

  goto: (event) ->
    console.info 'ComicView.goto'
    event.preventDefault()
    @views.main.set_image $(event.currentTarget).attr( 'src' )

  next: (event) ->
    console.info 'ComicView.next'
    event.preventDefault()

  prev: (event) ->
    console.info 'ComicView.prev'
    event.preventDefault()

  keypress: (event) ->
    console.info event

### Router ###

class ComicRouter extends Backbone.Router
  routes:
    'config': 'config'
    '': 'index'
    ':id': 'view'
    ':id/p:page': 'view'

  initialize: ->
    console.info 'ComicRouter.initialize'

  config: ->
    console.info 'ComicRouter.config'

  # TODO: should be the list view
  index: ->
    console.info 'ComicRouter.index'
    new ComicView

  view: ( id, page ) ->
    console.info 'ComicRouter.view', id, page
    comic = new Comic( id: id )
    comic_view = new ComicView( model: comic )
    comic.fetch
      success: ( model, response, options ) =>
        console.info 'success', response, model.attributes
      error: ( model, xhr, options ) =>
        console.info 'error', xhr

### Initialize Application ###

router = new ComicRouter

# Bind event to navigation to update breadcrumbs
router.bind('all', ( route, args ) -> console.info( route, args ) )

Backbone.history.start()

