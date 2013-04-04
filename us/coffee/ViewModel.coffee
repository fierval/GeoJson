class @ViewModel
    constructor: () ->
      @violent = ["murder", "rape", "robbery", "assault"]
      @property = ["arson", "burglary", "larceny", "vehicle_theft"]
      @crime = ko.observableArray(if !$.bbq.getState("crimes")? then [] else $.bbq.getState("crimes").split(";"))
      @capitalize = (text) -> text.split('_').map((t) -> t.slice(0,1).toUpperCase() + t.slice(1)).join(' ')
      @crimes = [{crime: @violent, type:"violent"}, {crime: @property, type:"property"}]

      @arrange = ko.observable(if !$.bbq.getState("sort")? then false else (if $.bbq.getState("sort") == true then true else false))

      @ofType = (type) =>
        res = $.grep(@crimes, (c) -> c.type == type )[0]
        @crimes.indexOf(res)

      # clicked checkbox
      @get_crimes = () =>
        $.bbq.pushState({crimes: @crime().join(';')})
        true

      @sort_crime = () =>
        $.bbq.pushState({sort: @arrange()})
        true
