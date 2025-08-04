function requestFullscreen(element, options) {
  if (element.requestFullscreen) {
    element.requestFullscreen(options);
  } else if (element.mozRequestFullScreen) {
    element.mozRequestFullScreen(options);
  } else if (element.webkitRequestFullScreen) {
    element.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
  }
}

function exitFullscreen() {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.webkitExitFullScreen) {
    document.webkitExitFullScreen();
  }
}

/** @type {import("phoenix_live_view").HooksOptions} */
const Hooks = {};

Hooks.FullscreenButton = {
  fullscreen() {
    return document.documentElement.dataset.fullscreen === "true";
  },
  setFullscreen(value) {
    document.documentElement.dataset.fullscreen = value;
  },
  mounted() {
    this.onClick = () => {
      const newFullscreen = !this.fullscreen();
      this.setFullscreen(newFullscreen);

      if (newFullscreen) {
        const container = document.getElementById("scoringContainer");
        requestFullscreen(container, {
          navigationUI: "hide",
        });

        screen.orientation.lock("landscape").catch(() =>
          console.warn("Failed to lock screen orientation")
        );
      } else if (document.fullscreenElement) {
        exitFullscreen();
        screen.orientation.unlock();
      }
    };

    this.onFullscreenChange = () => {
      this.setFullscreen(!!document.fullscreenElement);
    };

    document.addEventListener("fullscreenchange", this.onFullscreenChange);
    this.el.addEventListener("click", this.onClick);
  },
  destroyed() {
    this.el.removeEventListener("click", this.onClick);
    document.removeEventListener("fullscreenchange", this.onFullscreenChange);
  },
};

export default Hooks;
