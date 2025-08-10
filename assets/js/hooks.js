/** @type {import("phoenix_live_view").HooksOptions} */
const Hooks = {};

Hooks.ScoreCard = {
  mounted() {
    const text = this.el.querySelector("text.scoreText");
    const next = this.el.querySelector("text.scoreNextText");

    const duration = 250;
    const easing = "cubic-bezier(1, 0, 0, 1)";
    let animating = false;

    async function animateScore() {
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
    }

    function updateDom(value) {
      text.innerHTML = value;
      next.innerHTML = value + 1;
    }

    const score = {
      _value: Number(text.innerHTML.trim()),
      set value(newScore) {
        const animate = newScore === this._value + 1;
        this._value = Number(newScore);

        if (animate) {
          animating = true;

          animateScore().then(() => {
            updateDom(this._value);
            animating = false;
          });
        } else {
          updateDom(this._value);
        }
      },
      get value() {
        return this._value;
      },
    };

    const DEBOUNCE = 350;

    let timeout;
    let waitingScore = null;
    let wait = false;

    const team = this.el.dataset.team;

    const handleCount = (newScore) => {
      if (newScore > score.value || wait) {
        score.value = newScore;
      } else if (waitingScore == null || newScore > waitingScore) {
        waitingScore = newScore;
        timeout = setTimeout(() => {
          score.value = newScore;
        }, DEBOUNCE);
      }
    };

    this.handleEvent("reset_score", (data) => {
      if (data.wait !== undefined) {
        wait = data.wait;
      }
      if (data[team] === undefined) {
        return;
      }
      timeout && clearTimeout();
      waitingScore = null;

      score.value = data[team];
    });

    this.el.addEventListener("click", () => {
      if (wait || animating) return;

      score.value += 1;

      this.pushEvent("score", { team }, (reply) => {
        if (reply.score !== undefined) {
          handleCount(reply.score);
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
