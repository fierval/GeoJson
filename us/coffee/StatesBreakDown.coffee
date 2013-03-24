class @StatesBreakDown extends BreakdownChart
  constructor: (id, data, color) ->
    super(id, data, color)

    @data
      .forEach(
                (d) =>
                  d.radius = @radius_scale(d.value)
                  d.x = Math.random() * @xDelta
                  d.y = Math.random() * @yDelta
              )
    @domain = d3.range(100, 1700, 200)
    @color_class =
      d3.scale.threshold().domain(@domain).range(("q#{i}-9" for i in [8..0]))

  create_vis: () =>
    super()
    # since we are using a threshold scale, we need to make sure we fall into the bucket
    # we promise to fall into in the legend text
    @legend = new Legend(@vis,
                         ((i) =>
                           @color_class(@domain[i] - 1)),
                         ["< 100", " < 300", "< 500", "< 700", "< 900",
                          "< 1100", "< 1300", "< 1500", "1500 or more"],
                         'Violent crimes per 100,000 population',
                         {x: 10, y: 40}
                        )
    @legend.show(true)
    @create_scale()

  get_group_data: (d) ->
    [d]

  get_group_title: (d) ->
    d.name

  display: () ->
    super()

    @groups.on "click", (d, i) =>
      @trigger_show_cities(d, i, this)

  show_details: (data) =>
    content =
      "Population: #{@fixed_formatter(data.value)}<br/>Violent: #{@fixed_formatter(data.violent)}<br />Property: #{@fixed_formatter(data.property)} <br />"
    content += "Violent Crime per 100,000: #{@percent_formatter(data.group)}"

    @tip = new Opentip("##{data.id}", content, "",
                       {style: "glass", target: true, showOn: "creation", stem: "middle", tiptJoint: "middle"})

  hide_details: (data) =>
    @tip?.hide()

  trigger_show_cities: (d, i) =>
    @force?.stop()
    @tip?.hide()

    @data
      .forEach(
                (d, i) =>
                  d.x = d.px = @getX(i)
                  d.y = d.py = @getY(i)
              )
    @force = d3.layout.force().nodes(@data).size([@width, @height]).on("tick", (e) =>
      @scatter(e, @data[i], i))
    @force.start()

  scatter: (e, state, i) =>
    # move an individual group out of sight
    move_group = (alpha) =>
      (d, i) =>
        d.x = if alpha < 0.01 then @width + 50 else d.px + 20 * (1 - alpha)
        d.y = @getY(i)

    @groups
      .each(move_group(e.alpha))
      .attr("transform", (d) ->
             "translate(#{d.x},#{d.y})")

    if @data[0].x > @width
      @force.stop()
      # remember the state in window location
      # and trigger window "hashchange" event to
      # actually show the cities
      $.bbq.pushState({'by_state': i})

  # this will actually show the cities
  show_cities: (i) =>
    data = @data[i].cities
    byCity = new AllStates(@id, data, @colorScheme, d3.range(100, 900, 100))
    if @data[i].id == "NEW_JERSEY" or @data[i].id == "CONNECTICUT"
      byCity.height = 900
      byCity.center = {x: byCity.width / 2, y: byCity.height / 2}
      byCity.max_range = 60
      byCity.scale()
      byCity.update_data()

    byCity.create_vis()
    byCity.display()
    byCity.bubble_scale.svg.attr("height", byCity.bubble_scale.height + 80)
    byCity.bubble_scale.svg
      .append("text")
      .attr("x", byCity.bubble_scale.width)
      .attr("y", byCity.bubble_scale.height + 20)
      .attr("text-anchor", "middle")
      .style("font-size", "18")
      .text(@data[i].name)

    byCity.bubble_scale.svg.attr("width", byCity.bubble_scale.width + 220)
    byCity.bubble_scale.svg
    .append("text")
    .attr("x", 0)
    .attr("y", byCity.bubble_scale.height + 60)
    .text("Click browser 'back' button to return to the states view")


