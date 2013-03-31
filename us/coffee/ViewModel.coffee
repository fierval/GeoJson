class @ViewModel
    constructor: () ->
      @violent = ["murder", "rape", "assault"]
      @property = ["burglary", "larceny", "vehicle_theft"]
      @crime = ko.observableArray(@violent)
      @capitalize = (text) -> text.split('_').map((t) -> t.slice(0,1).toUpperCase() + t.slice(1)).join(' ')
      @type = ko.observable("violent")
      @crimes = [{crime: @violent, type:"violent"}, {crime: @property, type:"property"}]

      @ofType = (type) =>
        res = $.grep(@crimes, (c) -> c.type == type )[0]
        @crimes.indexOf(res)

      @toggle_type = () =>
        if @type() == "violent"
          @type("property")
        else
          @type("violent")

      # clicked radio
      @get_crimes = () =>
        # normally, prevent the default click action
        # so click is reflected correctly on checkboxes
        ret = true
        res = {
          type: @type()
          crimes: (crime for crime in (@crimes[@ofType(@type())]).crime when crime in @crime())
        }

        # uncheced everything means checked everything
        if res.crimes.length == 0
          res.crimes = @crimes[@ofType(@type())].crime
          #update the observable
          for crime in res.crimes
            do (crime) => @crime.push crime

          # in this case we don't want to prevent the default click action
          # or the last checkbox will not be checked
          ret = false

        @current_crimes = res
        ret

      # clicked the check box
      @switch_crimes = (current) =>
        if not (current in @crimes[@ofType(@type())].crime)
          @toggle_type()

        @get_crimes()
