class @ByState extends @BubbleChart
  constructor: (id, data, color) ->
    super(id, data, color)

    @max_range = 90
    @scale()

    @data
      .forEach(
                (d) =>
                    d.radius = @radius_scale(d.value)
                    d.x = Math.random() * @width
                    d.y = Math.random() * @height
              )
    @domain = d3.range(100, 1700, 200)
    @color_class =
      d3.scale.threshold().domain(@domain).range(("q#{i}-9" for i in [8..0]))

  create_vis: () =>
    super()
    # since we are using a threshold scale, we need to make sure we fall into the bucket
    # we promise to fall into in the legend text
    @legend = new Legend(@vis,
                         ((i) => @color_class(@domain[i] - 1)),
                         ["< 100", " < 300", "< 500", "< 700", "< 900",
                          "< 1100", "< 1300", "< 1500", "1500 or more"],
                         'Violent crimes per 100,000 population',
                         {x: 10, y: 40}
                         )
    @legend.show(true)

    values = [100000, 1000000, 10000000]
    if !@bubble_scale? or !@bubble_scale.exists()
      @bubble_scale = new CircularScale("vis", "circularScale", "Circles are sized by population", @radius_scale, values, {x:800, y: -670})
    else
      @bubble_scale.refresh(@radius_scale, values)


  show_details: (data) =>
    content =
      "Population: #{@fixed_formatter(data.value)}<br/>Violent: #{@fixed_formatter(data.violent)}<br />Property: #{@fixed_formatter(data.property)} <br />"
    content += "Violent Crime per 100,000: #{@percent_formatter(data.group)}"

    @tip = new Opentip("##{data.id}", content, data.name, {style: "glass", target: true, showOn: "creation", stem: "middle", tiptJoint: "middle"})

  hide_details: (data) =>
    @tip?.hide()