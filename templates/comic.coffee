
###
Keybindings:
Next        right arrow
Previous    left arrow
Fullscreen  f
Hide/Unhide h
###

### Config ###

# Set config to defaults if it hasn't been initialized
localStorage['comic'] ?= JSON.stringify (
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

  url: -> "/static/content/demo/#{@id}.json"

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

  render: ->
    console.info 'PreviewView.render'

    if( @model.get('pages') != undefined )
        pages = @model.get('pages')
        html = for i, src of pages
          "<li><img data-index=\"#{i}\" class=\"thumbnail\" src=\"#{src}\" /></a></li>"

    $(@el).html "<ol>#{html}</ol>"


class MainView extends Backbone.View
  events:
    'click .rotate': 'rotate'

  initialize: ->
    console.info 'MainView.initialize'
    _.bindAll @
    @rotation = config.rotation     # Initialize to config value, allow for changing

  render: ->
    console.info 'MainView.render', @current_page

    $(@el).css( 'height', $(window).height() )  # Need to manually size to prevent truncating images
          .css( 'line-height', $(window).height()+'px' )
    if( @image )
        # Have the option to use the naturalHeight and naturalWidth html5 properties for image sizes
        $image = $(@image)
        $image.addClass( 'rotate' )
              .css( 'transform', '' )
              .css( 'margin', '0 auto' )
        $(@el).html $image

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

        if target.width / src.width > target.height / src.height
            $image.height( '100%' )
                  .css( 'display', 'block' )
        else
            $image.width( '100%' )
                  .css( 'display', '' )

        switch rotation
          when 90, 270
            scale = Math.min( target.height / $(@image).width(), target.width / $(@image).height() )

            if rotation == 90
                $image.css 'transform', "matrix( 0, #{scale}, #{-scale}, 0, 0, 0 )"
            else
                $image.css 'transform', "matrix( 0, #{-scale}, #{scale}, 0, 0, 0 )"

          when 180
            $image.css( 'transform', "matrix( -1, 0, 0, -1, 0, 0 )" )

        console.info "rotation", rotation

  set_page: ( page_num ) ->
    console.info 'MainView.set_page', page_num

    pages = @model.get('pages')

    # Create image element
    @image = new Image
    @image.src = pages[ page_num ]
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

  initialize: ( options ) ->
    console.info 'ComicView.initialize', options.page
    _.bindAll @
    @model.bind 'change', @render
    @current_page = options.page ? 0
    @views =
      main: new MainView( model: @model )
      preview: new PreviewView( model: @model )

    # Layout views
    $(@el).addClass( 'row-fluid' )
          .css( 'overflow', 'hidden' )
    $(@views.preview.el).addClass( 'span1' )
    $(@views.main.el).addClass( 'span11' )

    #$(window).on('orientationchange', ( event ) => console.info( 'orientation', @render() ) )
    $(window).bind( 'resize.app', @render )
             .bind( 'storage', @render )
             .bind( 'keypress', @keypress )

  remove: ->
    $(window).unbind( 'resize.app' )
             .unbind( 'storage' )
             .unbind( 'keypress' )
    super()

  render: ->
    console.info( 'ComicView.render', $(window).width(), $(window).height() )
    $(@el).html @views.preview.el
    $(@el).append @views.main.el
    @views.preview.render()
    @views.main.render()

  goto: ( event ) ->
    console.info 'ComicView.goto'
    event?.preventDefault()
    @current_page = parseInt( $(event.currentTarget).data('index') )
    @views.main.set_page( @current_page )

  next: ( event ) ->
    console.info 'ComicView.next'
    event?.preventDefault()
    @current_page = ( @current_page + 1 ) % @model.get('pages').length
    @views.main.set_page( @current_page )

  prev: ( event ) ->
    console.info 'ComicView.prev'
    event?.preventDefault()
    @current_page = ( @current_page - 1 + @model.get('pages').length ) % @model.get('pages').length
    @views.main.set_page( @current_page )

  toggle_nav: ->
    console.info 'ComicView.toggle_nav'
    if $(@views.preview.el).css( 'display' ) != 'none'
        $(@views.preview.el).hide()
        $(@views.main.el).addClass( 'span12' )
                         .removeClass( 'span11' )
    else
        $(@views.preview.el).show()
        $(@views.main.el).addClass( 'span11' )
                         .removeClass( 'span12' )
    @views.main.render()

  keypress: ( event ) ->
    console.info 'keypress', event
    switch event.keyCode
      when 39 # right arrow
        @.next()
      when 38 # up arrow
        console.info 'up arrow'
      when 37 # left arrow
        @.prev()

    switch event.charCode
      when 104 # h
        @.toggle_nav()
      when 102 # f
        console.info 'full screen'
      when 99 # c
        console.info 'config'

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
    comic_view = new ComicView( { model: comic, page: page } )
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

