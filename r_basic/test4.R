rolls <- expand.grid(die, die)
prob <- c("1" = 1/8, "2" = 1/8, "3" = 1/8, "4" = 1/8, "5" = 1/8, "6" = 3/8)
rolls$value <- rolls$Var1 + rolls$Var2
rolls$prob1 <- prob[rolls$Var1]
rolls$prob2 <- prob[rolls$Var2]
rolls$prob <- rolls$prob1 * rolls$prob2
sum(rolls$value * rolls$prob)
