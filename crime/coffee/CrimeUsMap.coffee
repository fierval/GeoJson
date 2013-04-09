# id - id of the container to create the map in
# geometry - geometrical data in TopoJson
# data - crime data
# color - Cynthia Brewer's color scheme
class @CrimeUsMap extends UsMap
  constructor: (id, geometry, data, color, domain) ->
    super(id, geometry)

    @delay = 4000
    @data = data
    @allStates = new AllStates(id, d3.values(data), color, domain)
    @crimes = []

  display: () =>
    @allStates.crimes = @crimes
    @allStates.update_data()
    @allStates.cleanup()

    super()
    @legend = new Legend(@enclosingContainer,
                         ((i) => @allStates.color_class(@allStates.domain[i] - 1)),
                         @allStates.legend_text(),
                         'Crime per 100,000 population',
                         {x: 75, y: 40}
                        )
    @legend.show(true)

    @enclosingContainer.attr("class", @allStates.colorScheme)

    color_class = (state) =>
      @allStates.color_class(@data[state.toUpperCase()].group)

    @states = @states.style("fill", null).attr("class", (d) -> color_class(d.properties.name))
    @states = @states.attr("stroke-width", 2)
              .attr("stroke", (d) -> d3.rgb($(this).css("fill")).darker())

    @create_cities()

  show_details: (data) =>
    @allStates.show_details(@data[data.properties.name.toUpperCase()])

  hide_details: (data) =>
    @allStates.hide_details(@data[data.properties.name.toUpperCase()])