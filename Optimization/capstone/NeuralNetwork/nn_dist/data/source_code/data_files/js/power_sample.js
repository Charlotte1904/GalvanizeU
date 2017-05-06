"use strict";
/**
Copyright (c) 2015 The Chromium Authors. All rights reserved.
Use of this source code is governed by a BSD-style license that can be
found in the LICENSE file.
**/

require("./event.js");
require("./event_registry.js");

'use strict';

global.tr.exportTo('tr.model', function () {

  var Event = tr.model.Event;
  var EventRegistry = tr.model.EventRegistry;

  /**
   * A sample that contains a power measurement (in W).
   *
   * @constructor
   * @extends {Event}
   */
  function PowerSample(series, start, powerInW) {
    Event.call(this);

    this.series_ = series;
    this.start_ = start;
    this.powerInW_ = powerInW;
  }

  PowerSample.prototype = {
    __proto__: Event.prototype,

    get series() {
      return this.series_;
    },

    get start() {
      return this.start_;
    },

    set start(value) {
      this.start_ = value;
    },

    get powerInW() {
      return this.powerInW_;
    },

    set powerInW(value) {
      this.powerInW_ = value;
    },

    addBoundsToRange: function (range) {
      range.addValue(this.start);
    }
  };

  EventRegistry.register(PowerSample, {
    name: 'powerSample',
    pluralName: 'powerSamples'
  });

  return {
    PowerSample: PowerSample
  };
});