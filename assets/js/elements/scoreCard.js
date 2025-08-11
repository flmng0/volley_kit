import { svg, render } from "lit-html";

export class ScoreCard extends HTMLElement {
  static observedAttributes = ["score"];

  constructor() {
    super();
  }

  connectedCallback() {
    this.score = Number(this.getAttribute("score"));

    const query = window.matchMedia("(prefers-reduced-motion: reduce)");
    this.reducedMotion = query.matches;
    query.addEventListener("change", () => {
      this.reducedMotion = query.matches;
      if (this.reducedMotion) {
        this.animating = false;
      }
    });

    const shadow = this.attachShadow({ mode: "open" });

    const style = document.createElement("style");
    style.textContent = `
      @import '/assets/css/app.css';
      :host { display: contents; }
    `;

    const root = svg`
      <svg 
        class="${this.getAttribute("class")}"
        viewBox="0 0 24 16"
        stroke="none"
        fill="currentColor"
        width="100%"
        height="100%"
      >
        <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle" class="currentText">${this.score}</text>
        <text x="50%" y="150%" dominant-baseline="central" text-anchor="middle" class="nextText opacity-0">${this.score + 1}</text>
      </svg>
    `;

    shadow.appendChild(style);
    render(root, shadow);

    this.currentText = shadow.querySelector(".currentText");
    this.nextText = shadow.querySelector(".nextText");
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

    const transform = [{ transform: "translateY(0)" }, { transform: "translateY(-100%)" }];

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
    if (name !== "score" || this.currentText === undefined || this.nextText === undefined) {
      return;
    }

    this.score = Number(newValue);

    if (!this.reducedMotion && Number(newValue) === Number(oldValue) + 1) {
      await this.runAnimation();
    }

    this.currentText.textContent = this.score;
    this.nextText.textContent = this.score + 1;
  }
}

customElements.define("score-card", ScoreCard);
