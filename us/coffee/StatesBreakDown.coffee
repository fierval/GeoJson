class @StatesBreakDown extends BreakdownChart
  constructor: (id, data, color, domain) ->
    super(id, data, color)

    @domain = if domain? then domain else d3.range(100, 1700, 200)
    @color_class =
      d3.scale.threshold().domain(@domain).range(("q#{i}-9" for i in [8..0]))

    @crimes = []
    @legend_text =
      () =>
        text = ("< #{e}" for e in @domain)
        text.push("#{@domain[@domain.length - 1]} or more")
        text

  create_vis: () =>
    super()

    # since we are using a threshold scale, we need to make sure we fall into the bucket
    # we promise to fall into in the legend text
    @legend = new Legend(@vis,
      ((i) => @color_class(@domain[i] - 1)),
      @legend_text(),
      'Crime per 100,000 population',
      {x: 75, y: 40}
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

    if !@help_tip? and $.bbq.getState('by_state') == ''
      circle = $(".cell##{@data[Math.ceil(Math.random() * 11 + 11)].id}")
      @help_tip = new Opentip(circle,
                    "<p style='font-size:17px'>Click me!</p>",
                    { borderWidth: 3, stemLength: 18, stemBase: 20, style: "glass", target: true, borderColor: "#317CC5" })
      @help_tip.show()
      d3.timer () =>
                @help_tip.hide()
                true
               ,3000

  show_details: (data) =>
    content =
        "Population: #{@fixed_formatter(data.value)}<br/>Crime: #{@fixed_formatter(d3.sum(data[crime] for crime in @crimes))}<br />"
    content += "Crime per 100,000: #{@percent_formatter(data.group)}"

    @tip = new Opentip("##{data.id}", content, "",
                       {style: "glass", target: true, showOn: "creation", stem: "middle", tiptJoint: "middle"})

  hide_details: (data) =>
    @tip?.hide()

  trigger_show_cities: (d, i) =>
    @tip?.hide()

    @data
      .forEach ((d, i) =>
                  d.x = d.px = @getX(i)
                  d.y = d.py = @getY(i))

    # move them all beyond the screen
    that = this
    @groups.transition().duration(1200).attr("transform", (d, i) -> "translate(#{that.width + that.getX(i)}, #{that.getY(i)})")
    @cleanup()

    # remember the state in window location
    # and trigger window "hashchange" event to
    # actually show the cities
    d3.timer(
              (() ->
                $.bbq.pushState({'by_state': i})
                true),
        1400)

  # this will actually show the cities
  show_cities: (i) =>
    data = @data[i].cities
    @byCity = new AllStates(@id, data, @colorScheme, @domain)
    @byCity.crimes = @crimes
    if @data[i].id == "NEW_JERSEY" or @data[i].id == "CONNECTICUT"
      @byCity.height = 900
      @byCity.center = {x: @byCity.width / 2, y: @byCity.height / 2}
      @byCity.max_range = 60
      @byCity.scale()
      @byCity.update_data()

    @byCity.create_vis()
    @byCity.display()
    @byCity.bubble_scale.svg.attr("height", @byCity.bubble_scale.height + 80)
    @byCity.bubble_scale.svg
      .append("text")
      .attr("x", @byCity.bubble_scale.width/2 + 5)
      .attr("y", @byCity.bubble_scale.height + 20)
      .attr("text-anchor", "middle")
      .style("font-size", "18")
      .text(@data[i].name)

    link = '<a href="#by_state">Back to the states view</a>'
    $("##{@byCity.bubble_scale.id}").append(link)

  update_data: () =>
    super()

    if @crimes.length > 0
      @data.forEach (d) =>
                    d.group = d3.sum(d[crime] for crime in @crimes) / d.value * 100000

  update_display: (state) =>
    @update_data()
    that = this

    if state?
      if !@byCity?
        @show_cities(state)
      else
        @byCity.crimes = @crimes
        @byCity.cleanup()
        @byCity.update_display()
    else
      @get_groups().selectAll("circle").transition().duration(1000).attr("class", (d) -> that.color_class(d.group))
        .each("end", (d) -> d3.select(this).attr("stroke", d3.rgb($(this).css("fill")).darker()))