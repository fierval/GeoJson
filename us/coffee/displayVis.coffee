$ ->
  view_id = $("#view_selection a.btn.active").attr("id");
  byState = null
  allStates = null
  crime_data = null
  map_data = null
  map = null
  charts = []
  colorScheme = 'PiYG'

  $("#view_selection a").click(() ->
    view_type = $(this).attr("id")
    view_id = view_type
    $("#view_selection a").removeClass("active")
    $(this).toggleClass("active"))

  toArray = (data) -> d3.map(data).values()
  String::startsWith = (str) -> this.slice(0, str.length) == str
  String::removeLeadHash = () -> if this.startsWith("#") then this.slice(1) else this.toString()

  render_all_states = () ->
    if !allStates?
      allStates = new @AllStates('vis', toArray(crime_data), colorScheme)
      charts.push(allStates)

    allStates.create_vis()
    allStates.display()

  render_by_state = (state) ->

    if !byState?
      byState = new @StatesBreakDown('vis', toArray(crime_data), colorScheme)
      charts.push(byState)

    byState.create_vis()
    byState.display()

    if state?
      byState.show_cities(state)

  render_map = (state) ->
    map = new @CrimeUsMap('vis', map_data, crime_data, colorScheme)
    map.create_vis()
    map.display()

  render = (type, state) ->
    switch type
      when  'all_states'
          render_all_states()
      when 'by_state'
          render_by_state(state)
      when 'map'
        if !map_data?
          d3.json "us.json", (map) ->
                  map_data = map
                  render_map(state)
        else
          render_map(state)

  load_visual = (type, state) ->
    if !crime_data?
      d3.json "crime.json",
             (data) ->
              crime_data = data
              render(type, state)
    else
      render(type, state)

  $(window).bind 'hashchange', (e) ->
    states = $.bbq.getState()
    view = ({id, value} for id, value of states)[0]

    for chart in charts
      do (chart) -> chart?.cleanup()

    # initial value: we just accessed the url
    if !view?
      load_visual(view_id)
    else
      view.id = view.value if view.id == 'view_selection'
      load_visual(view.id, if view.value == "" then undefined else view.value)
      $('#view_selection a').removeClass('active')
      $("#view_selection a##{view.id}").addClass('active')

  # action!
  $(window).trigger('hashchange')