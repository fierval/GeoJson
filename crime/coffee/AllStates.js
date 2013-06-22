// Generated by CoffeeScript 1.6.2
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.AllStates = (function(_super) {
    __extends(AllStates, _super);

    function AllStates(id, data, color, domain) {
      this.on_tick = __bind(this.on_tick, this);
      this.rearrange = __bind(this.rearrange, this);
      this.update_display = __bind(this.update_display, this);
      this.display = __bind(this.display, this);
      this.move_towards_center = __bind(this.move_towards_center, this);
      this.move_arranged = __bind(this.move_arranged, this);
      this.hide_details = __bind(this.hide_details, this);
      this.show_details = __bind(this.show_details, this);
      this.create_vis = __bind(this.create_vis, this);
      this.update_data = __bind(this.update_data, this);
      var i,
        _this = this;

      AllStates.__super__.constructor.call(this, id, data, color);
      this.height = 900;
      this.max_range = 90;
      this.scale();
      this.domain = domain != null ? domain : d3.range(100, 1700, 200);
      this.color_class = d3.scale.threshold().domain(this.domain).range((function() {
        var _i, _results;

        _results = [];
        for (i = _i = 8; _i >= 0; i = --_i) {
          _results.push("q" + i + "-9");
        }
        return _results;
      })());
      this.tips = {};
      this.map_group = d3.scale.threshold().domain(this.domain).range([4, 3, 2, 1, 0, -1, -2, -3, -4]);
      this.legend_text = function() {
        var e, text;

        text = (function() {
          var _i, _len, _ref, _results;

          _ref = this.domain;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            e = _ref[_i];
            _results.push("< " + e);
          }
          return _results;
        }).call(_this);
        text.push("" + _this.domain[_this.domain.length - 1] + " or more");
        return text;
      };
      this.crimes = [];
      this.boundingRadius = this.height / 2;
    }

    AllStates.prototype.update_data = function(set_crime_only) {
      var _this = this;

      return this.data.forEach(function(d) {
        var crime;

        if (_this.crimes.length > 0) {
          d.group = d3.sum((function() {
            var _i, _len, _ref, _results;

            _ref = this.crimes;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              crime = _ref[_i];
              _results.push(d[crime]);
            }
            return _results;
          }).call(_this)) / d.value * 100000;
        }
        if ((set_crime_only == null) || set_crime_only === false) {
          d.radius = _this.radius_scale(d.value);
          d.x = Math.random() * _this.width;
          d.y = Math.random() * _this.height;
          delete d.px;
          return delete d.py;
        }
      });
    };

    AllStates.prototype.create_vis = function() {
      var _this = this;

      AllStates.__super__.create_vis.call(this);
      this.tips = {};
      this.legend = new Legend(this.vis, (function(i) {
        if (i < _this.domain.length) {
          return _this.color_class(_this.domain[i] - 1);
        } else {
          return _this.color_class(_this.domain[_this.domain.length - 1] + 1);
        }
      }), this.legend_text(), 'Crime per 100,000 population', {
        x: 75,
        y: 40
      });
      this.legend.show(true);
      this.create_scale({
        x: this.width,
        y: -this.height + 30
      });
      this.search = new Search(this.id, this, (function(d) {
        return d.name;
      }), (function(data, text) {
        return $.grep(data, function(d) {
          return d.name === text;
        })[0];
      }), {
        x: this.width,
        y: -800
      });
      return this.search.create_search_box();
    };

    AllStates.prototype.show_details = function(data) {
      var content, crime, tip;

      content = "Population: " + (this.fixed_formatter(data.value)) + "<br/>Crime: " + (this.fixed_formatter(d3.sum((function() {
        var _i, _len, _ref, _results;

        _ref = this.crimes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          crime = _ref[_i];
          _results.push(data[crime]);
        }
        return _results;
      }).call(this)))) + "<br />";
      content += "Crime per 100,000: " + (this.percent_formatter(data.group));
      d3.select("#" + data.id).attr("stroke", "black").attr("stroke-width", 4);
      tip = this.tips[data.id];
      if (tip == null) {
        tip = new Opentip("#" + data.id, content, data.name, {
          style: "glass",
          fixed: true,
          target: true,
          tipJoint: "left bottom"
        });
        this.tips[data.id] = tip;
      } else {
        tip.setContent(content);
      }
      return tip.show();
    };

    AllStates.prototype.hide_details = function(data) {
      var _ref;

      if ((_ref = this.tips[data.id]) != null) {
        _ref.hide();
      }
      return d3.select("#" + data.id).attr("stroke", function(d) {
        return d3.rgb($(this).css("fill")).darker();
      }).attr("stroke-width", 2);
    };

    AllStates.prototype.move_arranged = function(alpha, slowdown) {
      var _this = this;

      return function(d) {
        var targetY;

        targetY = _this.center.y - (_this.map_group(d.group) / 8) * _this.boundingRadius;
        return d.y = d.y + (targetY - d.y + 30) * alpha * alpha * alpha * alpha * 160;
      };
    };

    AllStates.prototype.move_towards_center = function(alpha, slowdown) {
      var _this = this;

      return function(d) {
        d.x = d.x + (_this.center.x - d.x) * _this.damper * alpha * 0.96;
        return d.y = d.y + (_this.center.y - d.y + 50) * _this.damper * alpha * 0.96;
      };
    };

    AllStates.prototype.display = function() {
      this.update_data();
      return AllStates.__super__.display.call(this);
    };

    AllStates.prototype.update_display = function() {
      var circles,
        _this = this;

      this.update_data(true);
      circles = this.get_bubble(this.vis, this.data);
      circles.transition().duration(1500).attr("class", function(d) {
        return _this.color_class(d.group);
      }).each("end", function(d) {
        return d3.select(this).attr("stroke", d3.rgb($(this).css("fill")).darker());
      });
      return this.rearrange();
    };

    AllStates.prototype.rearrange = function() {
      var circles, force;

      this.cleanup();
      circles = this.get_bubble(this.vis, this.data);
      force = this.force_layout(circles, this.data, [this.xDelta, this.yDelta], (this.arranged ? this.move_arranged : this.move_towards_center), true);
      return force.start();
    };

    AllStates.prototype.on_tick = function(move, e, circles) {
      return circles.each(this.move_towards_center(e.alpha)).each(this.move_arranged(e.alpha)).attr("cx", function(d) {
        return d.x;
      }).attr("cy", function(d) {
        return d.y;
      });
    };

    return AllStates;

  })(this.BubbleChart);

}).call(this);
