rolldie <- function () {
  die <- 1:6
  prob = c(1/8, 1/8, 1/8, 1/8, 1/8, 3/8)
  res <- sample(die, size = 2, replace = TRUE, prob)
  sum(res)
}

rolls <- replicate(10000, rolldie())
qplot(rolls, binwidth = 1)

