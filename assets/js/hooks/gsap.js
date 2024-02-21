import { gsap } from "gsap"
import { Flip } from "gsap/Flip"

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

    gsap.set(oldScore, { y: 0, opacity: 100, rotateX: 0 })
    gsap.to(oldScore, { y: 20, opacity: 0, rotateX: 60 })

    gsap.from(score, { y: -20, opacity: 0 })
  }
}
