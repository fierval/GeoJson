$ ->
  view_id = $("#view_selection a.btn.active").attr("id");
  byState = null
  allStates = null

  $("#view_selection a").click () ->

    view_id = $(this).attr("id")
    $('#view_selection a').removeClass('active')
    $(this).toggleClass("active")
    load_visual(view_id)

  toArray = (data) -> d3.map(data).values()
  String::startsWith = (str) -> this.slice(0, str.length) == str
  String::removeLeadHash = () -> if this.startsWith("#") then this.slice(1) else this.toString()

  render_all_states = (data) ->
    allStates = new @AllStates('vis', toArray(data), 'PiYG')
    allStates.create_vis()
    allStates.display()

  render_by_state = (data) ->
    byState = new @StatesBreakDown('vis', toArray(data), 'PiYG')
    byState.create_vis()
    byState.display()

  load_visual = (type) ->
    switch type
      when  'all_states'
        d3.json "crime.json",
                (data) ->
                  render_all_states(data)

      when 'by_state'
        d3.json "crime.json",
                (data) ->
                  render_by_state(data)
  # action!
  load_visual(view_id)