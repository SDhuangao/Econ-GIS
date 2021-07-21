library(tidyverse)
# 例如一个 tibble 数据框
tibble(x = 1:10, y = 2:11, z = 3:12) -> df

# 循环每个变量求和并打印出来
df %>% 
  mutate_all(.funs = function(x){
    sum(x) %>% 
      print()
  })

df %>% 
  mutate_at(c("x", "y"), .funs = function(x){
    sum(x) %>% 
      print()
  })