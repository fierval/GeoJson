class @BreakdownChart extends BubbleChart
  constructor: (id, data, color) ->
    super(id, data, color)

    @width = 1200
    # regulates the maximum radius of a bubble
    @max_range = 40
    @scale()

    @xStart = 50
    @yStart = 50
    @yDelta = 150
    @xDelta = 100

    #recompute the global center
    @center = {x: @xDelta / 2, y: @yDelta / 2}

    # how many "charts" do we have per line?
    @groupsPerLine = Math.floor((@width - @xStart) / @xDelta)

  display: () =>
    that = this

    # figure out container height
    lines = Math.ceil(@data.length / @groupsPerLine)

    @height = lines * @yDelta + @yStart + 10
    $("#vis").css("height", "#{Math.max(700, @height)}px") # cf. BubbleChart create_vis(), which sets it to 700px
    @vis.attr("height", @height)
    @vis.select("svg").attr("height", @height)

    #will display groups
    @groups =
      @vis.selectAll("g.cell")
        .data(@data, (d) -> d.id)
        .enter()
        .append("g")
        .attr("id", (d) -> d.id)
        .attr("class", "cell")
        .attr("transform", (d, i) => "translate(#{@getX(i)}, #{@getY(i)})")
        .each((d) -> that.plot(d3.select(this), that.get_group_data(d), false)) # false means we are using different force layout for each plot

    @groups.append("text")
      .attr("x", @center.x)
      .attr("y", @yDelta)
      .attr("text-anchor", "middle")
      .text((d) -> that.get_group_title(d))

  getX: (i) =>
    @xStart + @xDelta * (i % @groupsPerLine)

  getY: (i) =>
    @yStart + @yDelta * Math.floor(i / @groupsPerLine)