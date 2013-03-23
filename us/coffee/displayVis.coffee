$ ->
  view_id = $("#view_selection a.btn.active").attr("id");
  byState = null
  data = null

  $("#view_selection a").click(() ->

    view_id = $(this).attr("id")
    $('#view_selection a').removeClass('active')
    $(this).toggleClass("active"))

  render_by_state = (data) ->
    byState = new @ByState('vis', d3.map(data).values(), 'YlOrRd')
    byState.create_vis()
    byState.display()

  load_visual = (type) ->
    switch type
      when  'by_state'
        if data == null
          d3.json("crime.json",
                  (data) ->
                    render_by_state(data))
      else
        render_by_state(data)

  load_visual(view_id)