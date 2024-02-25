export const MatchCode = {
  mounted() {
    this.el.addEventListener('input', function(event) {
      this.value = this.value
        .toUpperCase()
        .split("")
        .filter((c) => this.dataset.alphabet.includes(c))
        .join("");
    })
  }
}
