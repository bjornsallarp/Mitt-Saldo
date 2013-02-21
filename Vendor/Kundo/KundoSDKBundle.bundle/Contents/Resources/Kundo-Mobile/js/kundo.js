var _gaq = _gaq || [];

Kundo = {
    READY_CALLED: false,
    API: null,
    FORUM: null,

    TOPIC_MAPPING: {
        "Q": {
            "full": "Ställ en fråga",
            "compact": "Fråga",
            "popular": "Vanliga frågor"
        },
        "S": {
            "full": "Lämna ett förslag",
            "compact": "Förslag",
            "popular": "Populära förslag"
        },
        "P": {
            "full": "Rapportera problem",
            "compact": "Problem",
            "popular": "Vanliga problem"
        },
        "B": {
            "full": "Ge beröm",
            "compact": "Beröm",
            "popular": "Beröm"
        }
    },

    /*
        iOS intercepts all http calls, and captures preregistered ones. So by
        setting the URL of this iframe, it's possible to communicate between
        the web view and native code. kund-o:// is the scheme
        for native code interaction.
    */
    createBridge: function() {
        var nativeBridge = document.createElement("iframe");
        nativeBridge.setAttribute("style", "display:none; height:0; width:0");
        nativeBridge.setAttribute("frameborder","0");
        document.documentElement.appendChild(nativeBridge);
        return nativeBridge;
    },

    /*
        jQuery appends a ui-loading class to the HTML element when autoInitialize
        is set to false, so we have to remove it manually on pagebeforechange.
    */
    fix_loading: function(){
        var root = $("html");
        if (root.hasClass("ui-loading")) {
            root.removeClass("ui-loading");
        }
    },

    /*
        This is called by native code as a response
        to the bridgeReady event
    */
    ready: function(slug, userEmail, userName, close_button) {
        if (!slug) {
            throw new Error("You need to supply a slug to the ready call");
        }

        // Remove close button unless called explicitly said it's needed
        close_button = close_button || false;
        if (!close_button) {
            $(".kundo-close").remove();
        }

        // Create "API" as a global variable
        Kundo.API = new KundoAPI(slug);

        // Fetch initial forum data here, to save time for later
        Kundo.FORUM = null;
        Kundo.fetch_forum();

        // Initialize Google Analytics
        _gaq.push(['_setAccount', 'UA-6180691-10']);
        (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();

        // Prevent timing issues when there's a delay between events being
        // attached and ready method being called.
        Kundo.READY_CALLED = true;
        $.mobile.initializePage();
    },

    /*
        Fetch initial data about the forum
    */
    fetch_forum: function(callback) {
        callback = callback || function(){};
        if (Kundo.FORUM) {
            callback(Kundo.FORUM);
            return;
        }

        Kundo.API.GET.properties({
            callback: function(data){
                Kundo.FORUM = data[0];
                callback(Kundo.FORUM);
            }
        });
    },

    /*
        Track mobile usage using Google Analytics
    */
    log_analytics: function(path) {
        if (location.hostname == 'localhost') return;
        var url = '/mobile/' + Kundo.API.slug + '/' + path;
        _gaq.push(['_trackPageview', url]);
    },

    /*
        jQuery Mobile does not support query parameters in the URL by default,
        so we patch it in.
    */
    patch_changepage: function(event, data){
        if (!Kundo.READY_CALLED) return;

        if (typeof data.toPage === "string") {
            var url = $.mobile.path.parseUrl(data.toPage),
                $page = $(url.hash.replace(/\?.*$/, "")),
                params = Kundo.API.qs_to_obj(url.hash.replace(/^.*\?/, ""));

            data.options.dataUrl = url.href;
            data.options.params = params;

            $.mobile.changePage($page, data.options);
            event.preventDefault();
        }
    },

    /*
        Route to the correct controller based on hash, and send in the
        values from the query string as parameters.
    */
    route: function(event, data){
        if (!Kundo.READY_CALLED) return;

        var page = data.toPage;
        var params = data.options.params;
        if (page.attr("id") == "select-type") {
            Kundo.Controllers.selecttype();
            Kundo.log_analytics("select-type");
        } else if (page.attr("id") == "feedback-form") {
            Kundo.Controllers.feedbackform(params.type);
            Kundo.log_analytics("feedback-form?type=" + params.type);
        } else if (page.attr("id") == "dialog-page") {
            Kundo.Controllers.dialogpage(params.id);
            Kundo.log_analytics("dialog-page?id=" + params.id);
        }
    },

    Templates: {
        html_for_message: function(message, error, icon){
            error = error || false;
            icon = icon || "alert"
            return '<div class="kundo-message ' + ((error)?"error":"") + '">' +
                    '<span class="ui-icon ui-icon-' + icon + '"></span>' +
                    '<span class="message">' + message + '</span>' +
                '</div>';
        },
        html_for_user: function(data) {
            var user = data.user,
                image = '<img width="47" height="47" src="' + user.gravatar_image + '">',
                name = '<strong>' + user.first_name + '</strong>',
                work_title = '<span class="title">' + user.work_title + '</span>',
                time = '<time datetime="' + data.pub_date + '">' + data.pub_date + '</time>';
            return image + name + ((user.work_title)?work_title:"") + time;
        }
    },

    /* Loading and sending of feedback form */
    Controllers: {
        selecttype: function(){
            var page = $("#select-type");
            Kundo.fetch_forum(function(forum){
                var title = forum.name;
                page.find("h1").text(title);
                $("title").text(title);

                var list = page.find("#dialog-types").empty();
                $.each(forum.enabled_topics, function(idx, topic_key){
                    list.append(
                        '<li><a href="#feedback-form?type=' + topic_key + '">' +
                            Kundo.TOPIC_MAPPING[topic_key].full +
                        '</a></li>'
                    );
                });
                list.listview("refresh");
            });
        },
        feedbackform: function(type) {
            type = type.toUpperCase();
            var DIALOGS_PER_PAGE = 5;
            var form = $("#feedback-form form");
            var search_container = form.find("#search-container");
            var dialog_list = $("#dialog-list");

            /* Set the page header */
            var title = Kundo.TOPIC_MAPPING[type].full;
            $("#feedback-form h1:first").text(title)
            $("title").text(title);

            /* Clear errors if a new form type */
            var current_type = form.find('#form_topic').val();
            if (current_type && current_type != type) {
                form[0].reset();
                form.find('.kundo-message.error').remove();
                search_container.empty();
                form.find("#form_title").autocomplete("destroy");
                dialog_list.empty();
            }

            /* Set up the correct policy URL */
            var policy_url = "http://kundo.se/org/" + Kundo.API.slug + "/policy-for-innehall/";
            form.find("#policy").attr("href", policy_url);

            /* Prepare form for sending, and set callbacks for responses */
            var api_url = Kundo.API.BASE_URL + "/" + Kundo.API.slug;
            form.attr("action", api_url);
            form.find('#form_topic').val(type);
            form.find('#form_error_url').val(api_url + "/js-endpoint/");
            form.find('#form_success_url').val(api_url + "/js-endpoint/");
            form.submit(function(){
                Kundo.API.POST.dialog(this, {
                    success: function(){
                        Kundo.fetch_forum(function(forum){
                            form.before(
                                '<div class="thanks">' +
                                    '<h2>Tack!</h2>' +
                                    '<p>' + forum.thankyou_message + '</p>' +
                                    '<p><a href=".">Skriv ett till inlägg</a></p>' +
                                '</div>'
                            ).remove();
                        });
                    },
                    error: function(data){
                        form.find('.kundo-message.error').remove();
                        $.each(data, function(name, message) {
                            form.find("[name='" + name + "']").after(
                                Kundo.Templates.html_for_message(message, true)
                            );
                        });
                    }
                });
            });

            /* Prepare title/search field */
            var SEARCH_MIN_LENGTH = 3;
            form.find("#form_title").autocomplete({
                minLength: SEARCH_MIN_LENGTH,
                delay: 800,
                source: function(request, response) {
                    var query = encodeURIComponent($.trim(request.term));
                    Kundo.API.GET.search(query, {
                        callback: function(data){
                            if (data.length == 0) return;

                            /* Fill the search box with results*/
                            var results = $("#search-results");
                            var refresh_needed = (results.find("li").length > 0);
                            results.empty();
                            var hit_len = Math.min(data.length, DIALOGS_PER_PAGE);
                            for (var i = 0; i < hit_len; i++) {
                                results.append(
                                    '<li><a href="#dialog-page?id=' + data[i].id + '">' +
                                        '<span class="ui-li-count">' + data[i].num_comments + ' svar</span>' +
                                        data[i].title +
                                    '</a></li>'
                                );
                            }
                            if (refresh_needed) {
                                results.listview("refresh");
                            }

                            /* Add message and link for opening the search result dialog */
                            var message = '<a href="#search-dialog" data-rel="dialog" class="ui-link">Hittade ' + hit_len + ' liknande inlägg</a>';
                            search_container
                                .empty().hide()
                                .append(Kundo.Templates.html_for_message(message, false, "search"))
                                .fadeIn();
                        }
                    });
                }
            }).keyup(function(event){
                if ($(this).val().length < SEARCH_MIN_LENGTH) {
                    search_container.empty();
                }
            });

            /* Fetch popular dialogs of a given type */
            if (dialog_list.find("li").length == 0) {
                var header = $("#feedback-form .ui-header:eq(1)");
                header.find("h1").text("Laddar...");
                Kundo.API.GET.popular(type, {
                    callback: function(data){
                        if (data.length == 0) {
                            header.remove()
                            return;
                        }
                        header.find("h1").text(Kundo.TOPIC_MAPPING[type].popular);
                        for (var i = 0, len = Math.min(data.length, DIALOGS_PER_PAGE); i < len; i++) {
                            dialog_list.append(
                                '<li><a href="#dialog-page?id=' + data[i].id + '">' +
                                    '<span class="ui-li-count">' + data[i].num_comments + ' svar</span>' +
                                    data[i].title +
                                '</a></li>'
                            );
                        }
                        dialog_list.listview('refresh');
                    }
                });
            }
        },
        dialogpage: function(id) {
            var dialog_page = $("#dialog-page");

            /* Render data about the current dialog */
            Kundo.API.GET.single(id, {
                callback: function(data){
                    var title = Kundo.TOPIC_MAPPING[data.topic].compact;
                    $("title").text(title);
                    dialog_page
                        .find("h1:first,").text(title).end()
                        .find("h2:first").text(data.title).end()
                        .find("#dialog-content").html(data.text).end()
                        .find(".meta:first").html(Kundo.Templates.html_for_user(data)).end();

                    var state = dialog_page.find("#state").empty();
                    state.parent().hide();
                    if (data.state) {
                        Kundo.fetch_forum(function(forum){
                            var org_name = forum.formal_name || forum.name;
                            var message = org_name + " har markerat att " + data.state;
                            state.html(
                                Kundo.Templates.html_for_message(message, false, "info")
                            );
                            state.parent().show();
                        });
                    }
                }
            });

            /* Render data about the current dialog's comments */
            var comments_box = dialog_page.find("#dialog-comments");
            comments_box.empty();
            Kundo.API.GET.comments(id, {
                sort: "pub_date",
                callback: function(data){
                    if (data.length == 0) {
                        comments_box.append('<li>Inga kommentarer.</li>');
                        comments_box.listview('refresh');
                        return;
                    }
                    for (var i = 0, len = data.length; i < len; i++) {
                        comments_box.append(
                            '<li data-theme="' + (data[i].is_org_reply? "d": "") + '">' +
                                '<div>' +
                                    data[i].text +
                                    '<div class="meta">' +
                                        Kundo.Templates.html_for_user(data[i]) +
                                    '</div>' +
                                '</div>' +
                            '</li>'
                        );
                    }
                    comments_box.listview('refresh');
                }
            });
        }
    },

    /*
        Initialize. Called from KundoViewController.m or
        directly at the bottom of this file when testing
    */
    init: function() {
        // Two different ways of loading this page:
        // Method 1: By loading http://kundo.se/mobile/<your-slug-here>/, through
        // either a normal browser, or sending the user to Safari from inside
        // your application.
        var match = /^\/mobile\/(.+)\//.exec(location.pathname);
        if (match !== null) {
            Kundo.ready(match[1], '', '');
            return;
        }

        // Method 2: Through a native library that listens to "kund-o://" urls
        // and triggers Kundo.ready from within application code
        Kundo.bridge = Kundo.createBridge();
        Kundo.bridge.src = "kund-o://bridgeReady";
    }
}

// Initialize everything
Kundo.init();

// Override routing in jQuery Mobile to better support query parameters
// in the hash part of the URL.
$(document).bind('pagebeforechange', Kundo.patch_changepage);
$(document).bind('pagebeforechange', Kundo.fix_loading);
$(document).bind('pagechange', Kundo.route);
