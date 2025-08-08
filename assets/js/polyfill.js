export function requestFullscreen(element, options) {
  if (element.requestFullscreen) {
    element.requestFullscreen(options);
  } else if (element.mozRequestFullScreen) {
    element.mozRequestFullScreen(options);
  } else if (element.webkitRequestFullScreen) {
    element.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
  }
}

export function exitFullscreen() {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.webkitExitFullScreen) {
    document.webkitExitFullScreen();
  }
}
