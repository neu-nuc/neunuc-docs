// Persist scroll-to-top behavior and small UX polish
document.addEventListener("DOMContentLoaded", () => {
  const top = document.querySelector("[data-md-component='top']");
  if (top) {
    top.addEventListener("click", () => {
      window.scrollTo({ top: 0, behavior: "smooth" });
    });
  }
});
