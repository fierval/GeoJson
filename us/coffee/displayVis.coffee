$ ->
  view_id = $("#view_selection a.btn.active").attr("id");
  byState = null
  allStates = null
  @data = null

  $("#view_selection a").click () ->

    view_id = $(this).attr("id")
    $('#view_selection a').removeClass('active')
    $(this).toggleClass("active")
    load_visual(view_id)

  render_all_states = () ->
    allStates = new @AllStates('vis', d3.map(@data).values(), 'PiYG')
    allStates.create_vis()
    allStates.display()

  render_by_state = () ->
    byState = new @StatesBreakDown('vis', d3.map(@data).values(), 'PiYG')
    byState.create_vis()
    byState.display()

  load_visual = (type) ->
    switch type
      when  'all_states'
        if !@data?
          d3.json "crime.json",
                  (data) ->
                    @data = data
                    render_all_states()
        else
          render_all_states()

      when 'by_state'
        d3.json "crime.json",
                (data) ->
                  @data = data
                  render_by_state()
  # action!
  load_visual(view_id)