# id - id of the container to create the map in
# geometry - geometrical data in TopoJson
# data - crime data
# color - Cynthia Brewer's color scheme
class @CrimeUsMap extends UsMap
  constructor: (id, geometry, data, color) ->
    super(id, geometry)

    @delay = 4000
    @data = data
    @allStates = new AllStates(id, d3.values(data), color)

  display: () =>
    super()
    @legend = new Legend(@enclosingContainer,
                         ((i) => @allStates.color_class(@allStates.domain[i] - 1)),
                         @allStates.legend_text(),
                         'Violent crimes per 100,000 population',
                         {x: 75, y: 40}
                        )
    @legend.show(true)

    @enclosingContainer.attr("class", @allStates.colorScheme)

    color_class = (state) =>
      name = state.toUpperCase()
      try
        @allStates.color_class(@data[name].group)
      catch error
        console.log(state)

    @states.style("fill", null).attr("class", (d) -> "q0-9").transition().duration(@delay).attr("class", (d) -> color_class(d.properties.name))

  show_details: (data) =>
    @allStates.show_details(@data[data.properties.name.toUpperCase()])

  hide_details: (data) =>
    @allStates.hide_details()