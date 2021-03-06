// Generated by CoffeeScript 1.7.1
(function() {
  $(function() {
    var allStates, byState, charts, colorScheme, crime_data, current_state, domain, get_view, load_visual, map, map_data, render, render_all_states, render_by_state, render_map, set_current_state, toArray, viewModel;
    byState = null;
    allStates = null;
    crime_data = null;
    map_data = null;
    map = null;
    charts = [];
    colorScheme = 'Spectral';
    current_state = '';
    domain = [10, 20, 50, 100, 200, 400, 800, 1500];
    viewModel = new window.ViewModel();
    ko.applyBindings(viewModel);
    toArray = function(data) {
      return d3.values(data);
    };
    String.prototype.startsWith = function(str) {
      return this.slice(0, str.length) === str;
    };
    String.prototype.removeLeadHash = function() {
      if (this.startsWith("#")) {
        return this.slice(1);
      } else {
        return this;
      }
    };
    render_all_states = function(crimes, update) {
      if (allStates == null) {
        allStates = new this.AllStates('vis', toArray(crime_data), colorScheme, domain);
        charts.push(allStates);
      }
      allStates.crimes = crimes;
      if ((update == null) || update === false) {
        allStates.create_vis();
        return allStates.display();
      } else {
        return allStates.update_display();
      }
    };
    render_by_state = function(state, crimes, update) {
      if (byState == null) {
        byState = new this.StatesBreakDown('vis', toArray(crime_data), colorScheme, domain);
        charts.push(byState);
      }
      byState.crimes = crimes;
      if ((update == null) || update === false) {
        byState.create_vis();
        byState.display();
        if (state != null) {
          return byState.show_cities(state);
        }
      } else {
        return byState.update_display(state);
      }
    };
    render_map = function(state, crimes) {
      map = new this.CrimeUsMap('vis', map_data, crime_data, colorScheme, domain);
      map.create_vis();
      map.crimes = crimes;
      return map.display();
    };
    render = function(type, state, crimes, update) {
      switch (type) {
        case 'all_states':
          return render_all_states(crimes, update);
        case 'by_state':
          return render_by_state(state, crimes, update);
        case 'map':
          if (map_data == null) {
            return d3.json("us.json", function(map) {
              map_data = map;
              return render_map(state, crimes);
            });
          } else {
            return render_map(state, crimes, update);
          }
      }
    };
    load_visual = function(type, state, crimes, update) {
      if (crime_data == null) {
        return d3.json("crime.json", function(data) {
          crime_data = data;
          return render(type, state, crimes, update);
        });
      } else {
        return render(type, state, crimes, update);
      }
    };
    set_current_state = function(id, st) {
      var ret;
      ret = id;
      if (st != null) {
        return [ret, st].join(";");
      } else {
        return ret;
      }
    };
    get_view = function() {
      var id, state, states, value, view, _i, _len;
      states = (function() {
        var _ref, _results;
        _ref = $.bbq.getState();
        _results = [];
        for (id in _ref) {
          value = _ref[id];
          _results.push({
            id: id,
            value: value
          });
        }
        return _results;
      })();
      for (_i = 0, _len = states.length; _i < _len; _i++) {
        state = states[_i];
        if ((state.id != null) && state.id !== "crimes") {
          view = state;
        }
      }
      return view;
    };
    $(window).bind('hashchange', function(e) {
      var chart, crimes, current, hash, update, view, _fn, _i, _len, _ref;
      hash = {};
      view = get_view();
      crimes = (_ref = $.bbq.getState("crimes")) != null ? _ref.split(";") : void 0;
      _fn = function(chart) {
        return chart != null ? chart.cleanup() : void 0;
      };
      for (_i = 0, _len = charts.length; _i < _len; _i++) {
        chart = charts[_i];
        _fn(chart);
      }
      if ((crimes == null) || (view == null)) {
        if (crimes == null) {
          crimes = viewModel.crime();
          hash["crimes"] = crimes.join(";");
        }
        if (view == null) {
          hash['all_states'] = '';
        }
        $.bbq.pushState(hash);
        return void 0;
      } else {
        current = set_current_state(view.id, view.value);
        update = current_state === current;
        current_state = current;
        viewModel.crime(crimes);
        $('#view_selection a').removeClass('active');
        $("#view_selection a#" + view.id).addClass('active');
        return load_visual(view.id, (view.value === "" ? void 0 : view.value), crimes, update);
      }
    });
    return $(window).trigger('hashchange');
  });

}).call(this);
