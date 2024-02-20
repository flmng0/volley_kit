import { gsap } from "gsap"
import { Flip } from "gsap/Flip"

gsap.registerPlugin(Flip)

export const Flip = {
  getConfig() {
    const duration = Number(this.el.getAttribute("data-flip-duration") || .3);
    const ease = this.el.getAttribute("data-flip-ease") || "power1-inOut";
    const absolute = !!this.el.getAttribute("data-flip-absolute");

    return { duration, ease, absolute }
  },
  
  beforeUpdate() {
    const flippers = this.el.querySelectorAll("[data-flip-id]");

    this.state = Flip.getState(flippers);
  },

  updated() {
    Flip.from(this.state, this.getConfig())
  }
}
