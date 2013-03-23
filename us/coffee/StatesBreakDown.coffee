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
                         ((i) => @color_class(@domain[i] - 1)),
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