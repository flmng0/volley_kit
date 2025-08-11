/** @type {import("phoenix_live_view").HooksOptions} */
const Hooks = {};

Hooks.ScoreCard = {
  mounted() {
    /** @type {import("./elements").ScoreCard} */
    const scoreElem = this.el.querySelector("score-card");

    const team = this.el.dataset.team;
    const debounceMs = 350;

    // Timeout tracking debounce
    let timeout;
    // Current score we're debouncing on
    let waitingScore = null;
    // Whether the next click should optimistic update (wait == false),
    // or should wait for the server to respond (wait == true).
    let wait = false;

    const handleCount = (newScore) => {
      if (newScore > score.value || wait) {
        scoreElem.setAttribute("score", newScore);
      } else if (waitingScore == null || newScore > waitingScore) {
        waitingScore = newScore;

        timeout = setTimeout(() => {
          scoreElem.setAttribute("score", newScore);
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

      scoreElem.setAttribute("score", data[team]);
    });

    this.el.addEventListener("click", () => {
      if (wait || scoreElem.animating) return;

      scoreElem.increment();

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
