class @Search
    constructor: (container, visual, mapData, processFoundItem, anchor) ->
      @id = "##{container.removeLeadHash()}"
      @visual = visual
      @data = visual.data
      @processFoundItem = processFoundItem
      @anchor = anchor
      # a list of classes to choose from
      # for the typeahead
      @entities = @data.map(mapData)
      $.fn.typeahead.Constructor::blur = () ->
        that = this;
        setTimeout((() -> that.hide()), 250)

    # creates the UI
    # for searching classes
    create_search_box: () =>
      findEntity = "#findEntity"

      if $(findEntity).length < 1
        html = '<div class="control-group" style="left: ' + @anchor.x + 'px; top: ' + @anchor.y + 'px; position: relative; width: 200px" >
                                    <label class="control-label" for="findEntity">Find:</label>
                                    <div class="controls">
                                        <input type="text" autocomplete="off" style="width: 150px" id="findEntity" name="findEntity">
                                    </div>
                            </div>'

        $(@id).append(html)
        $(findEntity).val("")
        that = this

        # create a "typehead" object for autocomplete functionality
        $(findEntity).typeahead(
          items: 10 # limit the menu to this number of items
          source: (query) =>
            # style manipulations for error and success/neutral
            error = () -> $(findEntity).closest('.control-group').addClass('error')
            good = () -> $(findEntity).closest('.control-group').removeClass('error')

            if @found?
              @visual.hide_details(@found)
              @found = null

            good()
            # select classes that start with our query string
            query = query.toUpperCase()
            res = (entity for entity in @entities when entity.slice(0, query.length).toUpperCase() == query)
            if res.length == 0
                error()
            res

          updater: (item) ->
            that.search(item)
          # custom highlighter: only highlight the leading digits of the class code
          # the default hightlights all occurences of the digit but that's not how we search
          highlighter: (item) ->
            "<strong>#{item.slice(0, this.query.length)}</strong>#{item.slice(this.query.length)}"
        )

        $(findEntity).focusout(
          () =>
            if @found?
              @visual.hide_details(@found)
        )
    # called when we have made our selection
    # by picking it from the typeahead menu
    search: (text) =>
      @found = @processFoundItem(@data, text)
      element = @visual.vis.select("##{@found.id}")

      @visual.show_details(@found, 0, element)
      text
