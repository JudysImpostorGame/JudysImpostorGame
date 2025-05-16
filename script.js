document.getElementById('language').addEventListener('change', function () {
  const selectedLang = this.value;
  console.log("Sprache gewechselt zu:", selectedLang);
  // Hier könntest du z.B. Inhalte dynamisch übersetzen
});

document.getElementById('startButton').addEventListener('click', function () {
  window.location.href = "modus-auswahl.html"; // Weiter zur nächsten Seite
});
