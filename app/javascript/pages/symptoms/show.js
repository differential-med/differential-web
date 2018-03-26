document.addEventListener('DOMContentLoaded', () => {
  const seeMores = document.querySelectorAll('.symptoms-show--diagnosis-see-more')

  seeMores.forEach(button => {
    button.addEventListener('click', () => {
      const box = button.parentElement.parentElement;
      const summary = box.querySelectorAll('.symptoms-show--diagnosis-summary')[0]

      if (summary) {
        summary.style.display = summary.style.display === "block" ? "none" : "block"
      }

      button.blur()
    })
  })

  const seeAnswers = document.querySelectorAll('.symptoms-show--see-anwswers')[0]

  if (seeAnswers) {
    seeAnswers.addEventListener('click', () => {
      const answers = document.querySelectorAll('.symptoms-show--answers')[0]

      if (answers) {
        answers.style.display = answers.style.display === "block" ? "none" : "block"
      }

      document.querySelectorAll('.symptoms-show')[0].classList.add('answer-shown')
    })
  }
})
