import { gsap } from "../../vendor/gsap.min.js"
import { Flip } from "../../vendor/gsap/Flip.min.js"

gsap.registerPlugin(Flip)

export const FlipContainer = {
  getConfig() {
    const duration = Number(this.el.getAttribute("data-flip-duration") || .3)
    const ease = this.el.getAttribute("data-flip-ease") || "power1-inOut"
    const absolute = !!this.el.getAttribute("data-flip-absolute")

    return { duration, ease, absolute }
  },
  
  beforeUpdate() {
    const flippers = this.el.querySelectorAll("[data-flip-id]")

    this.state = Flip.getState(flippers)
  },

  updated() {
    Flip.from(this.state, this.getConfig())
  }
}

export const ScoreCard = {
  beforeUpdate() {
    const score = this.el.querySelector(".score")

    this.oldScoreValue = score.innerText.trim()
  },

  updated() {
    const score = this.el.querySelector(".score")
    const oldScore = this.el.querySelector(".old-score")

    oldScore.textContent = this.oldScoreValue

    const tl = gsap.timeline()

    tl.fromTo(
      oldScore,
      { yPercent: 0, opacity: 1, rotateX: 0 },
      { yPercent: 20, opacity: 0, rotateX: 60, duration: 0.1 }
    )

    tl.fromTo(
      score,
      { yPercent: -20, opacity: 0, rotateX: -60 },
      { yPercent: 0, opacity: 1, rotateX: 0, duration: 0.3 },
      "-=30%"
    )
  }
}
