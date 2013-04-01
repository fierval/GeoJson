class @Search
# creates the UI
# for searching classes
  create_search_box: () =>
    findClass = "#findClass"

    if $(findClass).length < 1
      html = '<div class="control-group" style="left: ' + @legend_start + 'px; top: -315px; position: relative; width: 100px" >
                                  <label class="control-label" for="findClass">Find Class:</label>
                                  <div class="controls">
                                      <input type="text" autocomplete="off" style="width: 50px" id="findClass" name="findClass">
                                  </div>
                          </div>'

      $('#vis').append(html)
      $(findClass).val("")
      that = this

      # create a "typehead" object for autocomplete functionality
      $(findClass).typeahead(
        items: 10 # limit the menu to this number of items
        source: (query) =>
          # style manipulations for error and success/neutral
          error = () -> $(findClass).closest('.control-group').addClass('error')
          good = () -> $(findClass).closest('.control-group').removeClass('error')

          if @found?
            @hide_details(null, 0, @vis.select(@found))
            @found = undefined
          if query.length > 3
            error()
            []
          else
            # a list of classes to choose from
            # for the typeahead
            classes = @data.map((c) -> c.name)

            good()
            # select classes that start with our query string
            query = query.toUpperCase()
            res = (classs for classs in classes when classs.slice(0, query.length) == query)
            if query.length == 3
              if res.length == 0
                error()
              else
                @search_class(query)
            res

        updater: (item) ->
          that.search_class(item)
        # custom highlighter: only highlight the leading digits of the class code
        # the default hightlights all occurences of the digit but that's not how we search
        highlighter: (item) ->
          "<strong>#{item.slice(0, this.query.length)}</strong>#{item.slice(this.query.length)}"
      )
      # we want to perform lookup on focus
      # and if the textbox contains text already
      # we don't want to show the menu
      $(findClass).focus(
        () =>
          typeahead = $(findClass).data('typeahead')
          typeahead.lookup()
          if @found?
            typeahead.hide()
      )
  # called when we have made our selection
  # by picking it from the typeahead menu
  search_class: (text) =>
    @found = "#bubble_#{text}"
    element = @vis.select(@found)

    @show_details($.grep(@data, (d) -> d.name == text)[0], 0, element, @getOffsetRect($(@found)))
    text

  # our custom tooltip understands coordinates
  # that come from events. So we need to pass an object
  # that contains the right coordinate properties the same way
  # an even object contains them.
  getOffsetRect: (elem) =>
    box = elem.offset()
    radius = Math.round(elem.attr("r"))
    offset = {x: radius, y: radius}

    scrollTop = $(window).scrollTop()
    scrollLeft = $(window).scrollLeft()

    # return the object
    clientX: box.left - scrollLeft + offset.x
    clientY: box.top - scrollTop + offset.y
    pageX: box.left + offset.x
    pageY: box.top + offset.y

