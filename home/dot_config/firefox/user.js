// Firefox tuning for this host: Intel Pentium N3540 (Bay Trail, 4 slow cores),
// Intel HD Graphics (i915), 7.6 GB RAM, no swap, SSD.
//
// The bottleneck here is the CPU, not memory. The single biggest win is keeping
// video off the CPU: `vainfo --display drm` reports 16 profiles, but only
// MPEG2 and H.264 - there is NO VP9 and NO AV1 hardware decode on Bay Trail.
// YouTube serves VP9/AV1 by default, which would be decoded in software and
// saturate all four cores, so the media prefs below force H.264 instead.
//
// Copy or symlink this into the profile directory as user.js. Prefs here are
// re-applied on every start and override anything set in the UI.

// ---------------------------------------------------------------- video ----
// Hardware decode through VA-API.
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);

// No hardware VP9/AV1 on this GPU. Disabling the WebM/MSE path makes YouTube
// and friends fall back to H.264, which the GPU can decode.
user_pref("media.mediasource.webm.enabled", false);
user_pref("media.av1.enabled", false);

// ------------------------------------------------------------ rendering ----
user_pref("gfx.webrender.all", true);
user_pref("gfx.canvas.accelerated", true);
user_pref("layers.gpu-process.enabled", false);   // one less process on 4 cores

// ------------------------------------------------------- processes / RAM ----
// Default is 8 content processes. Fewer means less RAM and, more importantly
// on this CPU, less context switching.
user_pref("dom.ipc.processCount", 4);
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.sessionstore.interval", 60000);  // default 15s of disk churn

// ------------------------------------------------------------- CPU waste ----
// Speculative work that costs CPU and bandwidth for little gain on a slow box.
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);

// The accessibility engine is a measurable tax when nothing consumes it.
user_pref("accessibility.force_disabled", 1);

// ------------------------------------------------- telemetry and bloat ------
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("extensions.pocket.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// --------------------------------------------------------------- misc -------
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.download.useDownloadDir", true);
