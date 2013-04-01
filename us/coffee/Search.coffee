class @Search
    constructor: (container, visual, mapData, processFoundItem) ->
      @id = "##{container.removeLeadHash()}"
      @visual = visual
      @data = visual.data
      @mapData = mapData
      @processFoundItem = processFoundItem

    # creates the UI
    # for searching classes
    create_search_box: () =>
      findEntity = "#findEntity"

      if $(findEntity).length < 1
        html = '<div class="control-group" style="left: ' + 800 + 'px; top: -315px; position: relative; width: 100px" >
                                    <label class="control-label" for="findEntity">Find Class:</label>
                                    <div class="controls">
                                        <input type="text" autocomplete="off" style="width: 50px" id="findEntity" name="findEntity">
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
              @visual.hide_details(null, 0, visual.vis.select(@found))
              @found = undefined

            # a list of classes to choose from
            # for the typeahead
            entities = @data.map(mapData)

            good()
            # select classes that start with our query string
            query = query.toUpperCase()
            res = (entity for entity in entities when entity.slice(0, query.length) == query)
            if res.length == 0
                error()
            else
                @search(query)
            res

          updater: (item) ->
            that.search(item)
          # custom highlighter: only highlight the leading digits of the class code
          # the default hightlights all occurences of the digit but that's not how we search
          highlighter: (item) ->
            "<strong>#{item.slice(0, this.query.length)}</strong>#{item.slice(this.query.length)}"
        )
        # we want to perform lookup on focus
        # and if the textbox contains text already
        # we don't want to show the menu
        $(findEntity).focus(
          () =>
            typeahead = $(findEntity).data('typeahead')
            typeahead.lookup()
            if @found?
              typeahead.hide()
        )
      # called when we have made our selection
      # by picking it from the typeahead menu
      search: (text) =>
        @found = @processFoundItem(text)
        element = @vis.select(@found)

        @visual.show_details(@found, 0, element)
        text
