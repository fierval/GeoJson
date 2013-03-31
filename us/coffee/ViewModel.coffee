class @ViewModel
    constructor: () ->
      @violent = ["murder", "rape", "assault"]
      @property = ["burglary", "larceny", "vehicle_theft"]
      @crime = ko.observableArray([])
      @capitalize = (text) -> text.split('_').map((t) -> t.slice(0,1).toUpperCase() + t.slice(1)).join(' ')
      @crimes = [{crime: @violent, type:"violent"}, {crime: @property, type:"property"}]

      @ofType = (type) =>
        res = $.grep(@crimes, (c) -> c.type == type )[0]
        @crimes.indexOf(res)

      # clicked checkbox
      @get_crimes = (current) =>
        # normally, prevent the default click action
        # so click is reflected correctly on checkboxes
        ret = true
        res = (crime for crime in @crime())

        # uncheced everything means checked everything
        if res.length == 0
          res = @crimes[@ofType("violent")].crime
          #update the observable
          for crime in res
            do (crime) => @crime.push crime

          # we just "unclicked" it and now we want it checked again
          # don't suppress default behavior
          ret = !(current in @crimes[@ofType("violent")].crime)
        $.bbq.pushState({crimes: res.join(';')})
        ret