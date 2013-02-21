Access Kundo's API through Javascript
=====================================

This Javascript library can be used to access [Kundo's API](http://kundo.se/api-doc). It's meant to be used from both web sites, and web based applications.

Since browsers have strict cross-domain policies, the API uses a few tricks to work around them, while still maintaining an easy to use API for the developer. Fetching data is done through [JSONP](http://en.wikipedia.org/wiki/JSONP) (a technique for loading JSON through a script tag). Posting data can be done through posting via an hidden iframe, that posts data back to the parent page though postMessage.

Quick example
-------------
``` js
// Create a new API object, that will be used for all subsequent calls
var API = new KundoAPI("your-slug-here");

// Get all dialogs in your forum (API gives you 50 at a time)
API.GET.all({
  callback: function(data){ console.log(data); }
});
```

Dependencies
------------

* __jQuery__ - Used for cross browser jsonp, and minor convenience.
* __jQuery postMessage__ - A [polyfill](http://remysharp.com/2010/10/08/what-is-a-polyfill/) for cross browser [postMessage](https://developer.mozilla.org/en/DOM/window.postMessage) support. Used for sending data from a child iframe, back to the parent page.

All use of jQuery is constrained to three helper methods, so to support another library, you need to patch those methods. The postMessage plugin is only used to posting data, so if you're just fetching you don't need that plugin. Both of these are included in the repository.

Test with live data
-------------------

Clone this repository, and open [test_get.html](https://github.com/kundo/kundo-javascript/blob/master/test_get.html) or [test_post.html](https://github.com/kundo/kundo-javascript/blob/master/test_post.html) locally.

Examples of GET:s against the API
---------------------------------

``` js
// Create a new API object, that will be used for all subsequent calls
var API = new KundoAPI("your-slug-here");

// Get all dialogs in your forum (API gives you 50 at a time)
API.GET.all({
  callback: function(data){ console.log(data); }
});

// Get the next 50 dialogs in your forum
API.GET.all({
  start: 50,
  callback: function(data){ console.log(data); }
});

// Get the all dialogs of the type "Q".
// Other types are: Q (question), P (problem), S (suggestion), B (praise).
API.GET.topic("Q", {
  callback: callback_list("All questions")
});

// Search your forum for a specific phrase. The matched phrase will be
// highlighted with <span class="highlighted">phrase</span>
API.GET.search("fråga", {
  callback: function(data){ console.log(data); }
});

// We want to demo fetching one specific ID, but we don't know the ID of any
// posts in your specific forum. So lets get all dialogs, fetch the ID
// of the first dialogs we find, and make a request for that dialog.
// While we're there, get all the comments for that dialog too.
API.GET.all({
  sort: "pub_date",
  callback: function(data){
    var dialog_id = data[0].id;
    API.GET.single(dialog_id, {
      callback: function(data){ console.log(data); }
    });
    API.GET.comments(dialog_id, {
      sort: "pub_date",
      callback: function(data){ console.log(data); }
    });
  }
});
```

Examples of POST:s against the API
----------------------------------

``` js
// Success will be called if the dialog was posted correctly.
// You are free to provide any callback you like. In this case we
// remove all previous errors and show an alert.
function success(){
  $('.kundo_error').remove();
  alert("Your message was successfully posted");
}

// Error will be called if there's a validation error. It receives a
// objects with keys representing the keys that where incorrect, and
// values specifying what the error message was. In this case we remove
// all previous errors and create an error message connected to each
// input field.
function error(data){
  $('.kundo_error').remove();
  $.each(data, function(name, error) {
    $("[name='" + name + "']").after(
      $('<span class="kundo_error">' + error + '</span>')
    );
  });
}

// Create a new API object, that will be used for all subsequent calls
var API = new KundoAPI("your-slug-here");

// Post to the dialog, sending in the form that you want to post,
// and the two callback previous defined. The API will create a hidden
// iframe, post the data in that iframe, and receive the response, parse
// it and call either the success or error callbacks.
API.POST.dialog(form, {
  success: success,
  error: error
});
```

... and here's an example form that needs to be sent to the dialog method:

``` html
<form method="POST">
  <p>
    <label for="type_q">
      <input type="radio" name="topic" id="type_q" value="Q" checked> Question
    </label>
    <label for="type_p">
      <input type="radio" name="topic" id="type_p" value="P"> Problem
    </label>
    <label for="type_s">
      <input type="radio" name="topic" id="type_s" value="S"> Suggestion
    </label>
    <label for="type_b">
      <input type="radio" name="topic" id="type_b" value="B"> Praise
    </label>
  </p>
  <p>Title: <input name="title"></p>
  <p><textarea name="text"></textarea></p>
  <p>Your name: <input name="name"></p>
  <p>Your e-mail: <input name="useremail"></p>

  <input id="error_url" name="error_url" type="hidden" value="http://kundo.se/api/[your slug here]/js-endpoint/">
  <input id="success_url" name="success_url" type="hidden" value="http://kundo.se/api/[your slug here]/js-endpoint/">
  <p><button type="submit" onclick="post_dialog(this.form)">Send</button></p>
</form>
```
