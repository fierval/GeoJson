$ ->
  byState = null
  allStates = null
  crime_data = null
  map_data = null
  map = null
  charts = []
  colorScheme = 'Spectral'
  #colorScheme = 'PiYG'

  current_state = ''
  domain = [10, 20, 50, 100, 200, 400, 800, 1500]
  viewModel = new window.ViewModel()
  ko.applyBindings(viewModel)

  toArray = (data) -> d3.values(data)
  String::startsWith = (str) -> this.slice(0, str.length) == str
  String::removeLeadHash = () -> if this.startsWith("#") then this.slice(1) else this

  render_all_states = (crimes, update) ->
    if !allStates?
      allStates = new @AllStates('vis', toArray(crime_data), colorScheme, domain)
      charts.push(allStates)

    allStates.crimes = crimes
    if !update? or update == false
      allStates.create_vis()
      allStates.display()
    else
      allStates.update_display()

  render_by_state = (state, crimes, update) ->

    if !byState?
      byState = new @StatesBreakDown('vis', toArray(crime_data), colorScheme, domain)
      charts.push(byState)

    byState.crimes = crimes
    if !update? or update == false
      byState.create_vis()
      byState.display()
      if state?
        byState.show_cities(state)
    else
      byState.update_display(state)

  render_map = (state, crimes) ->
    map = new @CrimeUsMap('vis', map_data, crime_data, colorScheme, domain)
    map.create_vis()

    map.crimes = crimes
    map.display()

  render = (type, state, crimes, update) ->
    switch type
      when  'all_states'
          render_all_states(crimes, update)
      when 'by_state'
          render_by_state(state, crimes, update)
      when 'map'
        if !map_data?
          d3.json "us.json", (map) ->
                  map_data = map
                  render_map(state, crimes)
        else
          render_map(state, crimes, update)

  load_visual = (type, state, crimes, update) ->
    if !crime_data?
      d3.json "crime.json",
             (data) ->
              crime_data = data
              render(type, state, crimes, update)
    else
      render(type, state, crimes, update)

  set_current_state = (id, st) ->
    ret = id
    if st?
      [ret, st].join(";")
    else
      ret

  get_view = () ->
    states = ({id, value} for id, value of $.bbq.getState())
    view = state for state in states when state.id? and state.id != "crimes"
    view

  $(window).bind 'hashchange', (e) ->
    hash = {}

    view = get_view()
    crimes = $.bbq.getState("crimes")?.split(";")

    for chart in charts
      do (chart) -> chart?.cleanup()

    # no crimes in the url:
    # switching tabs.
    if !crimes? or !view?
      if !crimes?
        crimes = viewModel.crime()
        hash["crimes"] = crimes.join(";")

      # first time: no view yet
      if !view?
        hash['all_states'] = ''

      $.bbq.pushState(hash)
      undefined
    else
      current = set_current_state(view.id, view.value)
      update = current_state == current
      current_state = current

      viewModel.crime(crimes)
      $('#view_selection a').removeClass('active')
      $("#view_selection a##{view.id}").addClass('active')
      load_visual(view.id, (if view.value == "" then undefined else view.value), crimes, update)

  # action!
  $(window).trigger 'hashchange'