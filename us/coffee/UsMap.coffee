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

  create_vis: () =>
    $(@id).children().remove()
    $(@id).css("width", "#{@width}px")
    $(@id).css("height", "#{@height}px")

    @svg =
      d3.select(@id).append("svg")
        .style("position", "relative")
         .style("top", "100px")
        .attr("width", @width)
        .attr("height", @height)
        .attr("y", 100)

    # draw country
    @svg.selectAll(".country")
      .data(@country.geometries)
      .enter().append("path")
      .attr("class", "country")
      .attr("d", @path);

    @states =
      @svg.selectAll(".state")
        .data(topojson.object(@us, @us.objects.states).geometries)
        .enter()
        .append("path")
        .attr("d", @path)
        .style("fill", (d) =>
                @color(d.properties.name.charCodeAt(0)))

    @states.append("title").text((d) -> return d.properties.name)

    @svg.append("path")
      .datum(topojson.mesh(@us, @us.objects.states))
      .attr("d", @path)
      .attr("class", "state-boundary")

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