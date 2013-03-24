$ ->
  view_id = $("#view_selection a.btn.active").attr("id");
  byState = null
  allStates = null
  $.bbq.pushState({'view_selection': 'all_states'})

  $("#view_selection a").click () ->
    view_id = $(this).attr("id")
    $('#view_selection a').removeClass('active')
    $(this).toggleClass("active")

  toArray = (data) -> d3.map(data).values()
  String::startsWith = (str) -> this.slice(0, str.length) == str
  String::removeLeadHash = () -> if this.startsWith("#") then this.slice(1) else this.toString()

  render_all_states = (data) ->
    allStates = new @AllStates('vis', toArray(data), 'PiYG')
    allStates.create_vis()
    allStates.display()

  render_by_state = (data, state) ->

    if !state?
      byState = new @StatesBreakDown('vis', toArray(data), 'PiYG')
      byState.create_vis()
      byState.display()
    else
      if !byState?
        byState = new @StatesBreakDown('vis', toArray(data), 'PiYG')
        byState.create_vis()
        byState.display()
      byState.show_cities(state)

  load_visual = (type, state) ->
    switch type
      when  'all_states'
        d3.json "crime.json",
                (data) ->
                  render_all_states(data)

      when 'by_state'
        d3.json "crime.json",
                (data) ->
                  render_by_state(data, state)

 # load_visual(view_id)

  $(window).bind 'hashchange', (e) ->
    view = ({id, value} for id, value of $.bbq.getState())[0]
    view.id = view.value if view.id == 'view_selection'
    load_visual(view.id, if view.value == "" then undefined else view.value)
    $('#view_selection a').removeClass('active')
    $("#view_selection a##{view.id}").addClass('active')

  $(window).trigger("hashchange")