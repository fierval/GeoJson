class @UsMap
# id - id of the container where the map goes
# data - map data
  constructor: (id, data) ->
    @width = 960
    @id = "##{id.removeLeadHash()}"
    @us = data
    @height = 800;
    @color = d3.scale.linear().domain(['A'.charCodeAt(0), 'Z'.charCodeAt(0)]).range(['#ddc', '#fee3a6']);

    @country = topojson.object(@us, @us.objects.country)
    @projection = d3.geo.albersUsa()

    @path = d3.geo.path()
      .projection(@projection)
      .pointRadius(1)

  normalize_state: (state) =>
    state.toUpperCase().split(' ').join('_')

  create_vis: () =>
    $(@id).children().remove()
    $(@id).css("width", "#{@width}px")
    $(@id).css("height", "#{@height}px")

    @enclosingContainer =
      d3.select(@id).append("svg")
        .style("position", "relative")

    @svg = @enclosingContainer.append("svg")
        .style("position", "relative")
        .style("top", "100px")
        .attr("y", 100)
        .attr("width", @width)
        .attr("height", @height)

  display: () =>
    # draw country
    @svg.selectAll(".country")
      .data(@country.geometries)
      .enter().append("path")
      .attr("class", "country")
      .attr("d", @path);

    that = this
    @states =
      @svg.selectAll(".state")
        .data(topojson.object(@us, @us.objects.states).geometries, (d) -> d.properties.name)
        .enter()
        .append("path")
        .attr("d", @path)
        .attr("class", ".state")
        .attr("id", (d) => @normalize_state(d.properties.name))
        .style("fill", (d) =>
                @color(d.properties.name.charCodeAt(0)))
        .on("mouseover", (d,i) -> that.show_details(d,i,this))
        .on("mouseout", (d,i) -> that.hide_details(d,i,this))

    @svg.append("path")
      .datum(topojson.mesh(@us, @us.objects.states))
      .attr("d", @path)
      .attr("class", "state-boundary")

    @create_cities()

  create_cities: () =>
    # create a filtered cities collection
    cities =
      @us.objects.cities.geometries.filter((d) -> d.properties.scalerank < 4)

    cities_collection = {type: @us.objects.cities.type, geometries: cities}

    @svg.append("path")
      .datum(topojson.object(@us, cities_collection))
      .attr("d", @path)
      .attr("class", "place");

    @svg.selectAll(".place-label")
      .data(topojson.object(@us, cities_collection).geometries)
      .enter().append("text")
      .attr("class", "place-label")
      .attr("transform", (d) =>
             "translate(#{@projection(d.coordinates)})")
      .attr("dy", ".35em")
      .text((d) ->
             d.properties.name)

    @svg.selectAll(".place-label")
      .attr("x", (d) -> if d.coordinates[0] > -1 then 6 else -6)
      .style("text-anchor", (d) -> if d.coordinates[0] > -1 then "start" else "end")

    @svg.selectAll(".country-label")
      .data(@country.geometries)
      .enter().append("text")
      .attr("class", (d) ->
             "country-label #{d.id})")
      .attr("transform", (d) =>
             "translate(#{@path.centroid(d)})")
      .attr("dy", ".35em")
      .text((d) ->
             d.properties.name)

  cleanup: () =>
    undefined