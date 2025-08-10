/** @type {import("phoenix_live_view").HooksOptions} */
const Hooks = {};

Hooks.ScoreCard = {
  mounted() {
    const text = this.el.querySelector("text.scoreText");
    const next = this.el.querySelector("text.scoreNextText");

    const team = this.el.dataset.team;
    const debounceMs = 350;

    // State stating whether we're currently animating
    let animating = false;
    // Timeout tracking debounce
    let timeout;
    // Current score we're debouncing on
    let waitingScore = null;
    // Whether the next click should optimistic update (wait == false),
    // or should wait for the server to respond (wait == true).
    let wait = false;

    // Returns a promise that resolves once the score is finished animating
    async function animateScore() {
      animating = true;

      const duration = 250;
      const easing = "cubic-bezier(1, 0, 0, 1)";

      const wrap = (anim) =>
        new Promise((res, rej) => {
          anim.onfinish = () => res();
          anim.oncancel = () => rej();
        });

      /** @type {KeyframeAnimationOptions} */
      const options = { duration, easing };

      const transform = [
        { transform: "translateY(0)" },
        { transform: "translateY(-100%)" },
      ];

      const animations = [];

      animations.push(text.animate(transform, options));
      animations.push(next.animate(transform, options));

      // linear on purpose
      animations.push(text.animate({ opacity: [1, 0] }, duration));
      animations.push(next.animate({ opacity: [0, 1] }, duration));

      const promises = animations.map(wrap);

      await Promise.all(promises);

      animating = false;
    }

    function updateDom(value) {
      text.innerHTML = value;
      next.innerHTML = value + 1;
    }

    // Proxy object to handle side-effects of updating the score
    const score = {
      _value: Number(text.innerHTML.trim()),
      set value(newScore) {
        const animate = newScore === this._value + 1;
        this._value = newScore;

        if (animate) {
          animateScore().then(() => updateDom(this._value));
        } else {
          updateDom(this._value);
        }
      },
      get value() {
        return this._value;
      },
    };

    const handleCount = (newScore) => {
      if (newScore > score.value || wait) {
        score.value = newScore;
      } else if (waitingScore == null || newScore > waitingScore) {
        waitingScore = newScore;
        timeout = setTimeout(() => {
          score.value = newScore;
        }, debounceMs);
      }
    };

    // This is called on reset, undo, etc.
    //
    // Can be sent from the server at any time to sync the state of the
    // client.
    this.handleEvent("reset_score", (data) => {
      if (data.wait !== undefined) {
        wait = data.wait;
      }
      if (data[team] === undefined) {
        return;
      }
      timeout && clearTimeout(timeout);
      waitingScore = null;

      score.value = data[team];
    });

    this.el.addEventListener("click", () => {
      if (wait || animating) return;

      score.value += 1;

      this.pushEvent("score", { team }, (reply) => {
        if (reply.score !== undefined && !isNaN(Number(reply.score))) {
          handleCount(Number(reply.score));
        }
        timeout && clearTimeout(timeout);

        if (reply.wait !== undefined) {
          wait = reply.wait;
        }
      });
    });
  },
};

export default Hooks;
