
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
    rotation:       null    # The rotation for the pages when browsing (ex. 0, 90, 180, 270, null (best fit)).
    page_display:   1       # Number of pages to display on screen
    manga_mode:     false   # If the type can't be determined, browse in manga style
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
    $(@el).addClass 'span1'

  render: ->
    console.info 'PreviewView.render'

    if( @model.get('pages') != undefined )
        pages = @model.get('pages')
        html = for src in pages
          "<li><img class=\"thumbnail\" src=\"#{src}\" /></a></li>"

    $(@el).html "<ol>#{html}</ol>"


class MainView extends Backbone.View
  events:
    'click .rotate': 'rotate'

  initialize: ->
    console.info 'MainView.initialize'
    _.bindAll @
    $(@el).addClass 'span11'
    @rotation = config.rotation     # Initialize to config value, allow for changing

  render: ->
    console.info 'MainView.render'
    if( @image )
        # Have the option to use the naturalHeight and naturalWidth html5 properties for image sizes
        $image = $(@image)

        # Grab the source and target size for the projected image
        src =
            height: @image.naturalHeight
            width: @image.naturalWidth
            ratio: @image.naturalHeight / @image.naturalWidth
        target =
            height: $(window).height()
            width: $(@el).width()
            ratio: $(window).height() / $(@el).width()

        # Use local setting or calculate best fit
        rotation = @rotation
        rotation ?= if Math.abs( target.ratio - src.ratio ) < Math.abs( target.ratio - Math.pow( src.ratio, -1 ) ) then 0 else 270

        console.info "rotation", rotation

        # Create transformation matrix based off size of the container and image to fit
        switch rotation
          when 0
            scale = Math.min( target.width / src.width, target.height / src.height )
            target.transform = "matrix( #{scale}, 0, 0, #{scale}, #{(target.width - scale * src.width) / 2}, 0 )"
          when 90
            scale = Math.min( target.height / src.width, target.width / src.height )
            target.transform = "matrix( 0, #{scale}, #{-scale}, 0, #{(scale * src.height + target.width) / 2}, #{(target.height - scale * src.width) / 2} )"
          when 180
            scale = Math.min( target.width / src.width, target.height / src.height )
            target.transform = "matrix( #{-scale}, 0, 0, #{-scale}, #{(scale * src.width + target.width) / 2}, #{target.height} )"
          when 270
            scale = Math.min( target.height / src.width, target.width / src.height )
            target.transform = "matrix( 0, #{-scale}, #{scale}, 0, #{(target.width - scale * src.height) / 2}, #{(scale * src.width + target.height) / 2} )"

        $image.css( 'transform-origin', 'left top' )
              .css( 'transform', target.transform )
              .addClass( 'rotate' )
        $(@el).html $image
        #$(@el).append "<a href=\"#next\" class=\"next\">next</a><a href=\"#prev\" class=\"prev\">prev</a>"

  set_image: ( src ) ->
    console.info 'MainView.set_image'

    # Create image element
    @image = new Image
    @image.src = src
    @render()

  rotate: ->
    @rotation = (@rotation + 90) % 360
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
    $(@el).addClass( 'row-fluid' )
          .css( 'overflow', 'hidden' )
    @views =
      main: new MainView( model: @model )
      preview: new PreviewView( model: @model )

    #$(window).on('orientationchange', ( event ) => console.info( 'orientation', @render() ) )
    $(window).bind 'resize.app', @render
             .bind 'storage', @render

  remove: ->
    $(window).unbind 'resize.app'
             .unbind 'storage'
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

