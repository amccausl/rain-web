
###
Keybindings:
Next        right arrow
Previous    left arrow
Fullscreen  f
Hide/Unhide h
###

### Constants ###

transform_properties =
    [ 'transform'
    , '-ms-transform'
    , '-webkit-transform'
    , '-o-transform'
    , '-moz-transform'
    ]

transition_properties =
    [ 'transition'
    , '-moz-transition'
    , '-webkit-transition'
    ]

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
  tagName: 'aside'
  events:
    'change :input': 'update'
    'click .close': 'dismiss'

  initialize: ->
    console.info 'ConfigView.initialize'
    _.bindAll @
    $(@el).attr( 'id', 'config' )
    $(@el).addClass( 'modal' )

  render: ->
    console.info 'ConfigView.render'
    $(@el).html "
    <div class=\"modal-header\">
      <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button>
      <h3>Preferences</h3>
    </div>

    <div class=\"modal-body\">
      <form class=\"form-horizontal\">
        <div class=\"control-group\">
          <label class=\"control-label\" for=\"comic_config_rotation\">Rotation</label>
          <div class=\"controls\">
            <select name=\"rotation\" id=\"comic_config_rotation\">
              <option value=\"\" #{'selected="selected"' if config.rotation == null}>auto</option>
              <option value=\"0\" #{'selected="selected"' if config.rotation == 0}>none</option>
              <option value=\"90\" #{'selected="selected"' if config.rotation == 90}>90°</option>
              <option value=\"180\" #{'selected="selected"' if config.rotation == 180}>180°</option>
              <option value=\"270\" #{'selected="selected"' if config.rotation == 270}>270°</option>
            </select>
          </div>
        </div>

        <div class=\"control-group\">
          <label class=\"control-label\" for=\"comic_config_page-display\">2-page display</label>
          <div class=\"controls\">
            <input name=\"page_display\" type=\"checkbox\" id=\"comic_config_page-display\" #{'checked="checked"' if config.page_display == 2} />
          </div>
        </div>

        <div class=\"control-group\">
          <label class=\"control-label\" for=\"comic_config_background\">Background colour</label>
          <div class=\"controls\">
            <input name=\"background\" value=\"#{config.background}\" type=\"color\" id=\"comic_config_background\" />
          </div>
        </div>
      </form>
    </div>"

  update: ( event ) ->
    console.info 'ConfigView.update', event
    key = $(event.currentTarget).attr 'name'
    value = $(event.currentTarget).val()

    if( value == '' )
        value = null

    switch key
      when 'page_display'
        config.page_display = if event.currentTarget.checked then 2 else 1
      when 'rotation'
        config.rotation = if value == null then null else parseInt value
      when 'background'
        config.background = value

    console.info 'set', key, config[ key ]
    localStorage['comic'] = JSON.stringify config

  toggle: ->
    console.info 'ComicView.toggle'
    $(@el).toggleClass 'active'
    @render()

  dismiss: ->
    console.info 'ConfigView.dismiss'
    $(@el).removeClass 'active'


class ComicListView extends Backbone.View
  el: $ 'body'


class PreviewView extends Backbone.View
  tagName: 'nav'

  initialize: ->
    console.info 'PreviewView.initialize'
    _.bindAll @
    $(@el).css( 'overflow', 'hidden' )

  render: ->
    console.info 'PreviewView.render'

    if( @model.get('pages') != undefined )
        pages = @model.get('pages')
        html = for i, src of pages
          "<li><img data-index=\"#{i}\" class=\"thumbnail\" src=\"#{src}\" /></a></li>"

    $(@el).html "<ol style=\"width: #{$(@el).width()}px; height: #{$(window).height()}px; padding-right: 20px; margin-left: -30%; overflow-y: auto; overflow-x: hidden;\">#{html}</ol>"
    $(@el).css( 'height', $(window).height() )


class MainView extends Backbone.View
  events:
    'click .rotate': 'rotate'

  initialize: ->
    console.info 'MainView.initialize'
    _.bindAll @
    @rotation = config.rotation     # Initialize to config value, allow for changing
    @current_rotation = @rotation ? 0

  render: ->
    console.info 'MainView.render', @current_page

    $(@el).css( 'height', $(window).height() )  # Need to manually size to prevent truncating images
          .css( 'line-height', $(window).height()+'px' )

    if( config.background )
        $(@el).css( 'background-color', config.background )
    if( @image )
        # Have the option to use the naturalHeight and naturalWidth html5 properties for image sizes
        $image = $(@image)
        $image.addClass( 'rotate' )
              .css( 'margin', '0 auto' )
        $image.css( transform, '' ) for transform in transform_properties
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
        @current_rotation = @rotation
        @current_rotation ?= if Math.abs( target.ratio - src.ratio ) < Math.abs( target.ratio - Math.pow( src.ratio, -1 ) ) then 0 else 270

        if target.width / src.width > target.height / src.height
            $image.height( '100%' )
                  .css( 'display', 'block' )
        else
            $image.width( '100%' )
                  .css( 'display', '' )

        switch @current_rotation
          when 90, 270
            scale = Math.min( target.height / $(@image).width(), target.width / $(@image).height() )
            $image.css( transform, "rotate( #{@current_rotation}deg ) scale( #{scale} )" ) for transform in transform_properties

          when 180
            $image.css( transform, "rotate( #{@current_rotation}deg )" ) for transform in transform_properties

        console.info "rotation", @current_rotation

  set_page: ( page_num ) ->
    console.info 'MainView.set_page', page_num

    pages = @model.get('pages')

    # Create image element
    @image = new Image
    @image.src = pages[ page_num ]
    @render()

  rotate: ->
    @rotation = (@current_rotation + 90) % 360
    @render()


class ComicView extends Backbone.View
  events:
    'click .thumbnail': 'goto'
    'click .next': 'next'
    'click .prev': 'prev'

  el: $ 'body'

  initialize: ( options ) ->
    console.info 'ComicView.initialize', options.page
    _.bindAll @
    @model.bind 'change', @render
    @current_page = options.page ? 0
    @views =
      main: new MainView( model: @model )
      preview: new PreviewView( model: @model )
      config: new ConfigView

    # Layout views
    $(@el).addClass( 'row-fluid' )
          .css( 'overflow', 'hidden' )
    $(@views.preview.el).addClass( 'span1' )
    $(@views.main.el).addClass( 'span11' )

    $(@el).html( @views.preview.el )
          .append( @views.main.el )
          .append( @views.config.el )

    #$(window).on('orientationchange', ( event ) => console.info( 'orientation', @render() ) )
    $(window).bind( 'resize.app', @render )
             .bind( 'storage', @render )
             .bind( 'keydown', @keypress )

  remove: ->
    $(window).unbind( 'resize.app' )
             .unbind( 'storage' )
             .unbind( 'keydown' )
    super()

  render: ->
    console.info( 'ComicView.render', $(window).width(), $(window).height() )
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
      when 72 # h
        @toggle_nav()
      when 67 # c
        @views.config.toggle()
      when 39 # right arrow
        @next()
      when 38 # up arrow
        console.info 'up arrow'
      when 37 # left arrow
        @prev()
      when 27 # esc
        @views.config.dismiss()

### Router ###
active_view = null

class ComicRouter extends Backbone.Router
  routes:
    '': 'index'
    ':id': 'view'
    ':id/p:page': 'view'

  initialize: ->
    console.info 'ComicRouter.initialize'

  # TODO: should be the list view
  index: ->
    console.info 'ComicRouter.index'
    active_view?.remove()

  view: ( id, page ) ->
    console.info 'ComicRouter.view', id, page
    active_view?.remove()
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

