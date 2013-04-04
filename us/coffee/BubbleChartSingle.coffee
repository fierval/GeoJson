class @BubbleChart
  constructor: (id, data, color) ->
    # make sure we don't end up with "##id"
    @id = "##{id.removeLeadHash()}"
    @data = data
    @width = 940
    @height = 700

    # we may use many force layouts
    # and they need to be cleaned up when the time comes
    @forces = []

    # logarithm of 10 used to round things
    # to the closest power of 10
    @log2_10 = Math.log(10)
    @log10 = (x) => Math.floor(Math.log(x) / @log2_10)

    @colorScheme = if !color? then "RdGy" else color

    @percent_formatter = d3.format(",.2f")
    @fixed_formatter = d3.format(",d")

    # locations the nodes will move towards
    # depending on which view is currently being
    # used
    @center = {x: @width / 2, y: @height / 2}

    @xDelta = @width
    @yDelta = @height

    # used when setting up force and
    # moving around nodes
    @layout_gravity = -0.01
    @damper = 0.12
    @charge = (d) -> -Math.pow(d.radius, 2) / 8
    @friction = 0.9

    # these will be set in create_nodes and create_vis
    @vis = null
    @force = null

    # use Cynthia Brewer color brewer classes
    @color_class = (n) => "q1-6"

    @max_range = 65
    @max_amount = d3.max(@data, (d) -> d.value)
    @scale()

    # this interpolation will smoothely transition our colors
    # colros are defined by styles in the form qX-6 (X from 0 to 5)
    # so we can transition them with the animation.
    d3.interpolators.push(
                           (a, b) ->
                             re =  /^q([0-9])+/
                             ma = re.exec(a)
                             mb = re.exec(b)
                             if ma? && mb?
                               a = parseInt(ma[1])
                               b = parseInt(mb[1]) - a
                               (t) -> "q#{Math.round(a + b * t)}-9"
                         )

  get_circular_scale_values: =>
    i = @log10(@max_amount)

    # we only want three powers of ten max for the scale
    iMin = if i - 2 > 0 then i - 2 else 0
    (Math.pow(10, i--) while i >= iMin)

  scale: () =>
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, @max_amount]).range([2, @max_range])

  create_scale: (anchor) =>
    values = @get_circular_scale_values()

    if !@bubble_scale? or !@bubble_scale.exists()
      @bubble_scale = new CircularScale(@id, "circularScale", "Circles are sized by population", @radius_scale, values, if anchor? then anchor else {x:@width, y: -@height})
    else
      @bubble_scale.refresh(@radius_scale, values)

  # create svg at #vis and then
  # create circle representation for each node
  create_vis: () =>

    $(@id).children().remove()
    $(@id).css("width", "#{@width}px")
    $(@id).css("height", "#{@height}px")

    @vis = d3.select(@id)
    .append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")
      .attr("class",@colorScheme)

  get_bubble: (cell, data) =>
    cell.selectAll("circle")
    .data(data, (d) -> d.id)

  create_circles: (cell, data) =>
    that = this

    @get_bubble(cell, data)
    .enter()
    .append("circle")
    .attr("r", 0)
    .attr("class", (d) => @color_class(d.group))
    .attr("stroke-width", 2)
    .attr("stroke", (d) -> d3.rgb($(this).css("fill")).darker())
    .attr("id", (d) -> "#{d.id}")
    .on("mouseover", (d,i) -> that.show_details(d,i,this))
    .on("mouseout", (d,i) -> that.hide_details(d,i,this))

  update_circles: (cell, data) =>
    @get_bubble(cell, data)
    .attr("stroke", (d) -> d3.rgb($(this).css("fill")).darker())

  # oneForce set to true means we are re-using the same layout
  # otherwise set to false
  force_layout: (circles, data, size, move, oneForce, param) =>
    force = d3.layout.force()
      .nodes(data)
      .size(size)

    if oneForce? and oneForce
      @force?.stop()
      @force = force
    else
      @forces.push(force)

    force.gravity(@layout_gravity)
      .charge(@charge)
      .friction(@friction)
      .on "tick", (e) => @on_tick(move, e, circles, param)

  plot: (cell, data, oneForce) =>
    circles = @create_circles(cell, data)
    # Fancy transition to make bubbles appear, ending with the correct radius
    circles.transition().duration(2000).attr("r", (d) -> d.radius)

    force = @force_layout(circles, data, [@xDelta, @yDelta], @move_towards_center, oneForce)
    force.start()

  # Sets up force layout to display
  # all nodes in one circle.
  display: () =>
    @plot(@vis, @data, true)

  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * @damper * alpha
      d.y = d.y + (@center.y - d.y) * @damper * alpha

  on_tick: (move, e, circles, param) =>
    circles.each(move(e.alpha))
    .attr("cx", (d) -> d.x)
    .attr("cy", (d) -> d.y)

  load_overlay: (data, i, element) => false

  set_color_scheme: (color) =>
    @colorScheme = color
    @vis = @vis.attr("class", color)

  show_details: (data, i, element) =>
    undefined

  hide_details: (data, i, element) =>
    undefined

  # need to call this every time we move away
  # from this visual. If we use the same data for several
  # visuals and we move away to fast and force layouts are still happening,
  # weird things may (and will) occur
  cleanup: () =>
    @force?.stop()
    force?.stop() for force in @forces
    undefined
