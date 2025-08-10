export class ScoreCard extends HTMLElement {
  static observedAttributes = ["score"];

  constructor() {
    super();
  }

  connectedCallback() {
    this.score = Number(this.getAttribute("score"));

    const shadow = this.attachShadow({ mode: "open" });

    const rootSvg = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "svg",
    );
    rootSvg.setAttribute("viewBox", "0 0 24 16");
    rootSvg.setAttribute("stroke", "none");
    rootSvg.setAttribute("fill", "currentColor");
    rootSvg.setAttribute("width", "100%");
    rootSvg.setAttribute("height", "100%");

    const text = document.createElementNS("http://www.w3.org/2000/svg", "text");
    text.setAttribute("x", "50%");
    text.setAttribute("y", "50%");
    text.setAttribute("dominant-baseline", "central");
    text.setAttribute("text-anchor", "middle");
    text.textContent = this.score;

    const next = text.cloneNode();
    next.setAttribute("y", "150%");
    next.textContent = this.score + 1;

    const style = document.createElement("style");
    style.textContent = `svg {width: 100%; height: 100%}`;

    shadow.appendChild(style);
    shadow.appendChild(rootSvg);
    rootSvg.appendChild(text);
    rootSvg.appendChild(next);

    this.currentText = text;
    this.nextText = next;
  }

  async runAnimation() {
    this.animating = true;

    const duration = 250;
    const easing = "cubic-bezier(1, 0, 0, 1)";

    const text = this.currentText;
    const next = this.nextText;

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

    this.animating = false;
  }

  increment() {
    this.setAttribute("score", this.score + 1);
  }

  async attributeChangedCallback(name, oldValue, newValue) {
    if (
      name !== "score" ||
      this.currentText === undefined ||
      this.nextText === undefined
    ) {
      return;
    }

    this.score = Number(newValue);

    if (Number(newValue) === Number(oldValue) + 1) {
      await this.runAnimation();
    }

    this.currentText.innerHTML = this.score;
    this.nextText.innerHTML = this.score + 1;
  }
}

customElements.define("score-card", ScoreCard);
