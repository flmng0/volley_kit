// Place to register any window events that are used from
// JS.dispatch/2 events.

import { requestFullscreen, exitFullscreen } from "./polyfill";
import { liveSocket } from "./app";

window.addEventListener("vk:showmodal", function (e) {
  if (e.target instanceof HTMLDialogElement) {
    e.target.showModal();
    if (e.target.dataset.onclose) {
      e.target.onclose = () => {
        liveSocket.execJS(e.target, e.target.dataset.onclose);
      };
    }
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
