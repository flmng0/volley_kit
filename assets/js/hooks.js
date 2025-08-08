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

Hooks.ScoreCard = {
  mounted() {
    const target = this.el.querySelector("text.scoreText");

    const score = {
      _value: Number(target.innerHTML.trim()),
      set value(newScore) {
        this._value = Number(newScore);
        target.innerHTML = newScore;
      },
      get value() {
        return this._value;
      }
    };

    const DEBOUNCE = 350;
    let timeout;
    let waitingScore = null;
    let wait = false;

    const team = this.el.dataset.team;

    const handleCount = (newScore) => {
      if (newScore > score.value || wait) {
        score.value = newScore;
      }
      else if (waitingScore == null || newScore > waitingScore) {
        waitingScore = newScore;
        timeout = setTimeout(() => {
          score.value = newScore;
        }, DEBOUNCE);
      }
    }

    this.handleEvent("reset_score", (data) => {
      if (data.wait !== undefined) {
        wait = data.wait
      }
      if (data[team] === undefined) {
        return;
      }
      timeout && clearTimeout();
      waitingScore = null;

      score.value = data[team];
    })

    this.el.addEventListener("click", () => {
      if (!wait) {
        score.value += 1;
      }

      this.pushEvent("score", {team}, (reply) => {
        if (reply.score !== undefined) {
          handleCount(reply.score);
        }
        timeout && clearTimeout(timeout);

        if (reply.wait !== undefined) {
          wait = reply.wait;
        }
      })
    })
  }
}
    

export default Hooks;
