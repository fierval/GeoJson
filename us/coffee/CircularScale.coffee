class @CircularScale
    # vis - visualization container id (without preceding "#")
    # id - id of the legend  (without preceding "#")
    # scale - scaling function
    # values - array of values to reflet
    # anchor - where to pin it
    constructor: (vis, id, title, scale, values, anchor) ->
        @vis = vis.removeLeadHash()
        @anchor = anchor
        @id = id.removeLeadHash()

        @scale = scale
        @values = values.sort(d3.descending)
        @title = title

        @fixed_formatter = d3.format(",d")
        @delay = 750

        @create()

    exists: () =>
        $("##{@id}").length > 0

    compute_parameters: () =>
        # circles centered relative to the anchor.
        radiusMax = @scale(@values[0])
        @center = 
            x: @anchor.x + radiusMax
            y: @anchor.y + radiusMax

        @width = radiusMax * 2 + 10 
        @height = @width
        
        # extra horizontal passing to display text
        @padding = 100
        @radius = @height / 2

    elements: () =>
        [
            @svg.selectAll("circle").data(@values)
            @svg.selectAll("line").data(@values)
            @svg.selectAll("text").data(@values)
        ]

    # create the scale from scratch
    create: () =>
        @compute_parameters()

        style = "left:#{@anchor.x}px; top:#{@anchor.y}px; position:relative; width:#{@width + @padding}px;"
        title = "<p>#{@title}</p>"
        html = '<div id="' + @id + '" style="' + style + '">' + title + '</div>'

        $('#' + @vis).append(html)

        @svg = 
            d3.select("##{@id}")
            .append("svg")
            .attr("id", "svg_scale")
            .style("position", "relative")

        [circles, lines, text] = @elements()
        @enter(circles, lines, text)

    enter: (circles, lines, text) =>
        that = this

        if @svg.attr("width") < @width + @padding
            @svg = @svg.attr("width", @width + @padding).attr("height", @height + 10)

        circles
            .enter()
            .append("circle")
            .attr("class", "scaleCircle")
            .attr("cx", @width / 2)
            .attr("cy", (d) -> 2 * that.radius - that.scale(d))
            .attr("r", (d) -> 0)
        
        lines
            .enter()
            .append("line")
            .attr("class", "scaleCircle")
            .attr("x1", (d) -> that.width /2)
            .attr("y1", (d) -> 2 * (that.radius - that.scale(d)))
            .attr("x2", (d) -> that.width /2)
            .attr("y2", (d) -> 2 * (that.radius - that.scale(d)))
        
        text
            .enter()
            .append("text")
            .attr("text-anchor", "end")
            .attr("class", "scaleCircleLabel")
            .text((d) -> that.fixed_formatter(d))
            .attr("x", @width / 2)
            .attr("y", (d) -> 2 * (that.radius - that.scale(d)))
        
        @update(circles, lines, text)

    refresh: (scale, values) =>
        @scale = scale
        @values = values.sort(d3.descending)
        
        @compute_parameters()

        [circles, lines, text] = @elements() 
        @enter(circles, lines, text)
        @exit(circles, lines, text)
        @update(circles, lines, text)

    exit: (circles, lines, text) =>
        that = this
        circles.exit().transition().duration(@delay).ease("linear").attr("r", 0).remove()
        lines.exit().remove()
        text.exit().remove()

    update: (circles, lines, text) =>
        that = this
        circles.transition().duration(@delay)
            .attr("cx", @width / 2)
            .attr("cy", (d) -> 2 * that.radius - that.scale(d))
            .attr("r", (d) -> that.scale(d))

        lines.transition().duration(@delay)
            .attr("class", "scaleCircle")
            .attr("x1", (d) -> that.width /2)
            .attr("y1", (d) -> 2 * (that.radius - that.scale(d)))
            .attr("x2", (d) -> that.width + that.padding / 2)
            .attr("y2", (d) -> 2 * (that.radius - that.scale(d)))

        text.transition().duration(@delay)
            .text((d) -> that.fixed_formatter(d))
            .attr("x", (d) -> that.width + that.padding / 2)
            .attr("y", (d) -> 2 * (that.radius - that.scale(d)))