document.addEventListener("DOMContentLoaded", () => {
  const musicIcon = document.getElementById("musicIcon");
  const bgMusic = document.getElementById("bgMusic");

  if (!musicIcon || !bgMusic) return; // Sicherheitscheck

  // Zustand beim Laden prüfen
  if (localStorage.getItem("musicPlaying") === "false") {
    bgMusic.pause();
    musicIcon.textContent = "🔇";
  } else {
    bgMusic.play();
    musicIcon.textContent = "🎵";
    localStorage.setItem("musicPlaying", "true");
  }

  // Umschalten + speichern
  musicIcon.addEventListener("click", () => {
    if (bgMusic.paused) {
      bgMusic.play();
      musicIcon.textContent = "🎵";
      localStorage.setItem("musicPlaying", "true");
    } else {
      bgMusic.pause();
      musicIcon.textContent = "🔇";
      localStorage.setItem("musicPlaying", "false");
    }
  });
});
