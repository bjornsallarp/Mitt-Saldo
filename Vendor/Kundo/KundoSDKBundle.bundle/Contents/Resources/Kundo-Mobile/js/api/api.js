function KundoAPI(slug) {
  // Instance variables
  this.BASE_URL = "http://kundo.se/api";
  this.FORMAT = ".json";
  if (!slug) {
    throw new Error("Invalid slug. Please provide a proper slug.");
  }
  this.slug = slug;

  // Defaults
  var callback = function(data){ console.log(data); }
  var default_sorted_settings = {
    callback: callback,
    start: 0,
    sort: "-pub_date"
  }
  var default_plain_settings = {
    callback: callback,
    start: 0
  }

  // Helpers
  this.obj_to_qs = function(obj){
    var params = [];
    for (attrname in obj) {
      if (attrname == "callback") { continue; }
      params.push(attrname + "=" + decodeURIComponent(obj[attrname]));
    }
    return params.join("&")
  }
  this.qs_to_obj = function(qs){
    if (!qs) return {};
    var obj = {},
        parts = decodeURIComponent(qs).split("&");
    for (var i = 0, len = parts.length, key_value; i < len; i++) {
      key_value = parts[i].split("=");
      if (key_value.length == 2) {
        obj[key_value[0]] = key_value[1].replace(/\+/g, " ");
      }
    }
    return obj;
  }
  this.extend = function(obj1, obj2) {
    return jQuery.extend({}, obj1, obj2);
  }
  this.jsonp_get = function(url, settings) {
    var params = this.obj_to_qs(settings);
    url = this.BASE_URL + url + "?" + params;
    jQuery.ajax({ url: url, dataType: "jsonp", success: settings.callback });
  }
  this.post_via_iframe = function(url, form, settings) {
    url = this.BASE_URL + url;
    if (!jQuery.receiveMessage) {
      throw new Error(
        "Posting data through the API requires \"jQuery postMessage\", " +
        "which is available here: https://github.com/cowboy/jquery-postmessage"
      );
    }

    var iframe_name = "kundo_result_iframe";
    jQuery.receiveMessage(function(event){
      var data = that.qs_to_obj(event.data);
      if (!jQuery.isEmptyObject(data)) {
        settings.error(data);
      }
      else {
        settings.success();
      }
      $("#" + iframe_name).remove();
    });

    jQuery("body").append(jQuery('<iframe>', {
      name: iframe_name,
      id: iframe_name,
      style: "display: none"
    }));
    jQuery(form).attr("target", iframe_name);
    jQuery(form).attr("action", url);
  }

  // Allow access to "this" inside this.GET and this.POST
  var that = this;

  // Get data from your forum
  this.GET = {
    all: function(settings) {
      settings = that.extend(default_sorted_settings, settings);
      that.jsonp_get('/' + that.slug + that.FORMAT, settings);
    },
    single: function(dialog_id, settings) {
      if (!dialog_id || !typeof dialog_id == "number") {
        throw new Error("Invalid id. It should be numeric.");
      }
      settings = that.extend(default_plain_settings, settings);
      that.jsonp_get('/dialog/' + that.slug + '/' + dialog_id + that.FORMAT, settings);
    },
    properties: function(settings){
      settings = that.extend(default_plain_settings, settings);
      that.jsonp_get('/properties/' + that.slug + that.FORMAT, settings);
    },
    comments: function(dialog_id, settings) {
      if (!dialog_id || !typeof dialog_id == "number") {
        throw new Error("Invalid id. It should be numeric.");
      }
      settings = that.extend(default_sorted_settings, settings);
      that.jsonp_get('/comment/' + that.slug + '/' + dialog_id + that.FORMAT, settings);
    },
    topic: function(type, settings) {
      if (type != "Q" && type != "P" && type != "S" && type != "B") {
        throw new Error("Invalid topic type. Please use one of: Q, P, S, B.");
      }
      settings = that.extend(default_sorted_settings, settings);
      that.jsonp_get('/' + that.slug + '/' + type + that.FORMAT, settings);
    },
    popular: function(type, settings) {
      if (type != "Q" && type != "P" && type != "S" && type != "B") {
        throw new Error("Invalid topic type. Please use one of: Q, P, S, B.");
      }
      settings = that.extend(default_sorted_settings, settings);
      that.jsonp_get('/popular/' + that.slug + '/' + type + that.FORMAT, settings);
    },
    search: function(query, settings) {
      if (!query) { return; }
      query = decodeURIComponent(query);
      settings = that.extend(default_plain_settings, settings);
      that.jsonp_get('/search/' + that.slug + '/' + query + that.FORMAT, settings);
    }
  }

  // Post data to your forum
  this.POST = {
    dialog: function(form, settings) {
      if (!form) {
        throw new Error("You need to specify a valid form that will post the dialog");
      }
      else if (!settings.success || !settings.error) {
        throw new Error("You need to specify both a success and error callback");
      }
      that.post_via_iframe("/" + that.slug, form, settings);
    },
    comment: function(form, dialog_id, settings) {
      if (!form) {
        throw new Error("You need to specify a valid form that will post the comment");
      }
      else if (!dialog_id || !typeof dialog_id == "number") {
        throw new Error("Invalid dialog id. It should be numeric.");
      }
      else if (!settings.success || !settings.error) {
        throw new Error("You need to specify both a success and error callback");
      }
      that.post_via_iframe('/comment/' + that.slug + '/' + dialog_id, form, settings);
    },
    vote: function(form, dialog_id, settings) {
      if (!form) {
        throw new Error("You need to specify a valid form that will post the vote");
      }
      else if (!dialog_id || !typeof dialog_id == "number") {
        throw new Error("Invalid dialog id. It should be numeric.");
      }
      else if (!settings.success || !settings.error) {
        throw new Error("You need to specify both a success and error callback");
      }
      that.post_via_iframe('/vote/' + that.slug + '/' + dialog_id, form, settings);
    },
    report_dialog: function(form, dialog_id, settings) {
      if (!form) {
        throw new Error("You need to specify a valid form that will post the report");
      }
      else if (!dialog_id || !typeof dialog_id == "number") {
        throw new Error("Invalid dialog id. It should be numeric.");
      }
      else if (!settings.success || !settings.error) {
        throw new Error("You need to specify both a success and error callback");
      }
      that.post_via_iframe('/report-dialog/' + that.slug + '/' + dialog_id, form, settings);
    },
    report_comment: function(form, comment_id, settings) {
      if (!form) {
        throw new Error("You need to specify a valid form that will post the report");
      }
      else if (!comment_id || !typeof comment_id == "number") {
        throw new Error("Invalid comment id. It should be numeric.");
      }
      else if (!settings.success || !settings.error) {
        throw new Error("You need to specify both a success and error callback");
      }
      that.post_via_iframe('/report-comment/' + that.slug + '/' + comment_id, form, settings);
    }
  }
}
