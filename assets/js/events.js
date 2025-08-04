// Place to register any window events that are used from
// JS.dispatch/2 events.

window.addEventListener("vk:showmodal", function (e) {
  if (e.target instanceof HTMLDialogElement) {
    e.target.showModal();
  } else {
    console.warn(
      "Tried to send `vk:showmodal` event to non-dialog element!",
    );
  }
});

window.addEventListener("vk:copytext", function (e) {
  const input = e.target;

  e.target.select();

  navigator.clipboard
    .writeText(input.value)
    .catch(() => {
      document.execCommand("copy");
    });
});
