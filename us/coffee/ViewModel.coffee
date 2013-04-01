class @ViewModel
    constructor: () ->
      @violent = ["murder", "rape", "assault"]
      @property = ["arson", "burglary", "larceny", "vehicle_theft"]
      @crime = ko.observableArray([])
      @capitalize = (text) -> text.split('_').map((t) -> t.slice(0,1).toUpperCase() + t.slice(1)).join(' ')
      @crimes = [{crime: @violent, type:"violent"}, {crime: @property, type:"property"}]

      @ofType = (type) =>
        res = $.grep(@crimes, (c) -> c.type == type )[0]
        @crimes.indexOf(res)

      # clicked checkbox
      @get_crimes = () =>
        # normally, prevent the default click action
        # so click is reflected correctly on checkboxes
        res = (crime for crime in @crime())
        $.bbq.pushState({crimes: res.join(';')})
        true