/* ==============================
 * ===    practical prefs     ===
 * ============================== */

/* cache directory */
user_pref("browser.cache.disk.parent_directory", "/run/user/1000/firefox");

/* interval for saving session data to restore if firefox crashes.
 * default is 15000 milliseconds which is too short. */
user_pref("browser.sessionstore.interval", 120000);

/* link opening behaviour */
user_pref("browser.link.open_newwindow.override.external", 2);

/* scroll speed */
user_pref("mousewheel.default.delta_multiplier_x", 150);
user_pref("mousewheel.default.delta_multiplier_y", 150);

/* fix context menu clicking the first item */
user_pref("ui.context_menus.after_mouseup", true);

/* disable hold to show context menu */
user_pref("ui.click_hold_context_menus", false);

/* disable animations */
user_pref("toolkit.cosmeticAnimations.enabled", false);

/* ==============================
 * ===   privacy/annoyances   ===
 * ============================== */

/* enable userChrome/userContent */
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

/* do not show about:config warning */
user_pref("browser.aboutConfig.showWarning", false);

/* disable default browser check */
user_pref("browser.shell.checkDefaultBrowser", false);

/* disable Activity Stream stuff */
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.preload", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false); // [DEFAULT: false FF89+]
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false); // [FF66+]
user_pref("browser.newtabpage.activity-stream.default.sites", "");

/* disable pocket */
user_pref("extensions.pocket.enabled", false);

/* use mozilla's geolocation provider */
user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");

/* 0204: disable using the OS's geolocation service ***/
user_pref("geo.provider.ms-windows-location", false); // Windows
user_pref("geo.provider.use_corelocation", false); // Mac
user_pref("geo.provider.use_gpsd", false); // Linux

/* disable region updates */
user_pref("browser.region.network.url", "");
user_pref("browser.region.update.enabled", false);

/* set preferred website display language */
user_pref("intl.accept_languages", "en-US, en");

/* disable firefox auto-installing it's updates */
user_pref("app.update.auto", false);

/* disable bullshit search-engine updates */
user_pref("browser.search.update", false);

/* disable annoying recommendations */
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);

/* disable telemetry */
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);
user_pref("network.connectivity-service.enabled", false);

/* enable blocklists */
user_pref("extensions.blocklist.enabled", true);

/* disable checking downloaded files */
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.url", "");
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);

/* disable some system addons */
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("browser.ping-centre.telemetry", false);

/* disable autofill */
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.available", "off");
user_pref("extensions.formautofill.creditCards.available", false);
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("extensions.formautofill.heuristics.enabled", false);

/* disable more telemetry bullshit */
user_pref("extensions.webcompat-reporter.enabled", false);

/* disable predictions and prefetching */
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("network.http.speculative-parallel-limit", 0);

/* disable IPv6 which can be abused and leak data */
user_pref("network.dns.disableIPv6", true);

/* disable a potential proxy bypass */
user_pref("network.gio.supported-protocols", "");

/* disable apparently dangerous domain guessing */
user_pref("browser.fixup.alternate.enabled", false);

/* display the whole url */
user_pref("browser.urlbar.trimURLs", false);

/* disable live search suggestions and address bar leakages */
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.urlbar.dnsResolveSingleWordsAfterSearch", 0);

/* more suggestion settings */
user_pref("browser.urlbar.suggest.history", true);
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.openpage", true);
user_pref("browser.urlbar.suggest.topsites", false);

/* don't ask to save passwords */
user_pref("signon.rememberSignons", false);

/* don't write cache to disk in private browsing */
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);

/* enforce TLS 1.0 and 1.1 downgrades as session only */
user_pref("security.tls.version.enable-deprecated", false);

/* disable TLS1.3 0-RTT (round-trip time) */
user_pref("security.tls.enable_0rtt_data", false);

/* display warning on the padlock for "broken security" */
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);

/* display advanced information on Insecure Connection warning pages */
user_pref("browser.xul.error_pages.expert_bad_cert", true);

/* display "insecure" icon and "Not Secure" text on HTTP sites */
user_pref("security.insecure_connection_text.enabled", true);

/* disable graphite which has many security issues */
user_pref("gfx.font_rendering.graphite.enabled", false);

/* send less info on cross origin */
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

/* do not track */
user_pref("privacy.donottrackheader.enabled", true);

/* disable all DRM content (EME: Encryption Media Extension) */
user_pref("media.eme.enabled", false);

/* block popups */
user_pref("dom.disable_open_during_load", true);

/* limit events that can cause a popup */
user_pref("dom.popup_allowed_events", "click dblclick mousedown pointerdown");

/* disable autoplay of HTML5 media */
user_pref("media.autoplay.default", 5);

/* prevent scripts from moving and resizing open windows */
user_pref("dom.disable_window_move_resize", true);

/* disable push notifications */
user_pref("dom.push.enabled", false);

/* disable clipboard commands (cut/copy) from "non-privileged" content */
/* this is set to "true" because it breaks "click to copy" buttons */
user_pref("dom.allow_cut_copy", true);

/* disable insecure asm.js */
user_pref("javascript.options.asmjs", false);

/* disable accessiblity */
user_pref("accessibility.force_disabled", 1);

/* disable beacon analytics */
user_pref("beacon.enabled", false);

/* remove temp files opened with an external application */
user_pref("browser.helperApps.deleteTempFileOnExit", true);

/* disable page thumbnail collection */
user_pref("browser.pagethumbnails.capturing_disabled", true);

/* disable some devtools */
user_pref("devtools.chrome.enabled", false);
user_pref("devtools.debugger.remote-enabled", false);

/* remove special permissions for mozilla domains */
user_pref("permissions.manager.defaultsUrl", "");

/* enable an important security feature */
user_pref("security.csp.enable", true);

/* block all third party cookies */
user_pref("network.cookie.cookieBehavior", 1);
user_pref("browser.contentblocking.category", "custom");

/* disable social tracking */
user_pref("privacy.trackingprotection.socialtracking.enabled", true);

/* resist fingerprinting (it's set to false because it causes brakages) */
user_pref("privacy.resistFingerprinting", false);

/* disable some bullshit annoyances */
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
