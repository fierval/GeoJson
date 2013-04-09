class @Legend
# svg - svg cell to append the legend to
# color_class - function to convert from a number to a color class from colorbrewer.css
# data - an array of text data
# description - what does the legend indicate
# start {x, y} - starting position
# isVertical - should vertical layout be used instead of horizontal (false by default)
# helpText - a tooltip to pop-up in case we can display some helpful message
  constructor: (svg, color_class, data, description, start, isVertical, helpText) ->
    isVertical = if isVertical? then isVertical else false

    if(description?)
      @title =
        svg.append("text")
          .attr("x", start.x)
          .attr("y", start.y + if isVertical then 0 else 30)
          .attr("visibility", "hidden")
          .text(description)

      if helpText?
        @title =  @title.attr("fill", "#08C")
          .on("mouseover", () -> d3.select(this).style("cursor", "help"))
          .on("mouseout", () -> d3.select(this).style("cursor", "auto"))

        @title.append("title")
          .text(helpText)

    @legend = svg.selectAll("#vis_legend")
      .data(data)
      .enter().append("g")
      .attr("id", "vis_legend")
      .attr("visibility", "hidden")
      .attr("transform", (d, i) => this.translate(start, i, isVertical))

    @legend.append("circle")
      .attr("class", (d, i) -> color_class(i))
      .attr("r", 4)
      .attr("stroke-width", 1)
      .attr("stroke", (d,i) -> d3.rgb($(this).css("fill")).darker())

    @legend.append("text")
      .attr("x", 14)
      .attr("dy", ".35em")
      .text(String)

  show: (isVisible) =>
    @legend.attr("visibility", if isVisible then "visible" else "hidden")
    @title.attr("visibility", if isVisible then "visible" else "hidden")

  set_title: (text) =>
    @title.text(text)

  translate: (start, i, isVertical) =>
    if isVertical
      "translate(#{start.x}, #{start.y + 10 + i * 22})"
    else
      "translate(#{start.x + i * 65}, #{start.y})"
