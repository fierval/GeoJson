class @AllStates extends @BubbleChart
  constructor: (id, data, color, domain) ->
    super(id, data, color)
    @height = 900
    @max_range = 90
    @scale()

    @domain = if domain? then domain else d3.range(100, 1700, 200)
    @color_class =
      d3.scale.threshold().domain(@domain).range(("q#{i}-9" for i in [8..0]))

    @legend_text =
      () =>
        text = ("< #{e}" for e in @domain)
        text.push("#{@domain[@domain.length - 1]} or more")
        text

    @crimes = []

  update_data: () =>
    @data
    .forEach(
              (d) =>
                d.radius = @radius_scale(d.value)
                d.x = Math.random() * @width
                d.y = Math.random() * @height
                if @crimes.length > 0
                  d.group = d3.sum(d[crime] for crime in @crimes) / d.value * 100000
                delete d.px
                delete d.py
            )

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
    @create_scale({x:@width, y: -@height + 30})

  show_details: (data) =>
    content =
      "Population: #{@fixed_formatter(data.value)}<br/>Crime: #{@fixed_formatter(d3.sum(data[crime] for crime in @crimes))}<br />"
    content += "Crime per 100,000: #{@percent_formatter(data.group)}"

    @tip = new Opentip("##{data.id}", content, data.name, {style: "glass", target: true, showOn: "creation", stem: "middle", tiptJoint: "middle"})

  hide_details: (data) =>
    @tip?.hide()

  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * @damper * alpha
      d.y = d.y + (@center.y - d.y + 50) * @damper * alpha

  cleanup: () =>
    super()
    @tip?.hide()

  display: () =>
    @update_data()
    super()

  update_display: () =>
    @update_data()
    circles = @get_bubble(@vis, @data)

    # chained transitions to update fill color and stroke
    circles.transition().duration(1500)
      .attr("class", (d) => @color_class(d.group))
      .each("end", (d) -> d3.select(this).attr("stroke", d3.rgb($(this).css("fill")).darker()))

