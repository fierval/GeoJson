class @AllStates extends @BubbleChart
  constructor: (id, data, color, domain) ->
    super(id, data, color)
    @height = 900
    @max_range = 90
    @scale()

    @update_data()
    @domain = if domain? then domain else d3.range(100, 1700, 200)
    @color_class =
      d3.scale.threshold().domain(@domain).range(("q#{i}-9" for i in [8..0]))

    @legend_text =
      () =>
        text = ("< #{e}" for e in @domain)
        text.push("#{@domain[@domain.length - 1]} or more")
        text

  update_data: () =>
    @data
    .forEach(
              (d) =>
                d.radius = @radius_scale(d.value)
                d.x = Math.random() * @width
                d.y = Math.random() * @height
            )

  create_vis: () =>
    super()
    # since we are using a threshold scale, we need to make sure we fall into the bucket
    # we promise to fall into in the legend text
    @legend = new Legend(@vis,
                         ((i) => @color_class(@domain[i] - 1)),
                         @legend_text(),
                         'Violent crimes per 100,000 population',
                         {x: 10, y: 40}
                         )
    @legend.show(true)
    @create_scale({x:@width, y: -@height + 30})

  show_details: (data) =>
    content =
      "Population: #{@fixed_formatter(data.value)}<br/>Violent: #{@fixed_formatter(data.violent)}<br />Property: #{@fixed_formatter(data.property)} <br />"
    content += "Violent Crime per 100,000: #{@percent_formatter(data.group)}"

    @tip = new Opentip("##{data.id}", content, data.name, {style: "glass", target: true, showOn: "creation", stem: "middle", tiptJoint: "middle"})

  hide_details: (data) =>
    @tip?.hide()

  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * @damper * alpha
      d.y = d.y + (@center.y - d.y + 50) * @damper * alpha
