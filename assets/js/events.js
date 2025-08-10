// Place to register any window events that are used from
// JS.dispatch/2 events.

import { requestFullscreen, exitFullscreen } from "./polyfill";

window.addEventListener("vk:showmodal", function (e) {
  if (e.target instanceof HTMLDialogElement) {
    e.target.showModal();
  } else {
    console.warn("Tried to send `vk:showmodal` event to non-dialog element!");
  }
});

window.addEventListener("vk:copytext", function (e) {
  const input = e.target;

  e.target.select();

  navigator.clipboard.writeText(input.value).catch(() => {
    document.execCommand("copy");
  });
});

const fullscreen = {
  get enabled() {
    return document.documentElement.dataset.fullscreen === "true";
  },
  set enabled(value) {
    document.documentElement.dataset.fullscreen = !!value;
  },
};

window.addEventListener("fullscreenchange", () => {
  fullscreen.enabled = !!document.fullscreenElement;
});

window.addEventListener("vk:toggleFullscreen", (e) => {
  fullscreen.enabled = !fullscreen.enabled;

  if (fullscreen.enabled) {
    requestFullscreen(e.target, {
      navigationUI: "hide",
    });

    screen.orientation
      .lock("landscape")
      .catch(() => console.warn("Failed to lock screen orientation"));
  } else if (document.fullscreenElement) {
    exitFullscreen();
    screen.orientation.unlock();
  }
});
