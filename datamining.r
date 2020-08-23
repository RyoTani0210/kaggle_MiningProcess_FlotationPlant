data_fixed = readRDS("df_fixed.obj")

library(dplyr)
library(tidyr)
library(tidyverse)
library(lubridate)

columns = names(data_fixed)


data_test = data_fixed[1:1000,]

result = data_test %>% mutate( hour = round_date(date, unit = "hours")) %>% 
  select(-("date")) %>% group_by(hour) %>%
  summarise_all(
    mean
  )


extractFeaturesByHour = function(df, statnames, date= "date")
  {
  # 集計オブジェクト作成
  groupby_hour = data_test %>% mutate(hour = round_date(date, unit = "hours")) %>%
    select(-("date")) %>% group_by(hour)
  # 特徴量別集計
  results = NULL # 計算結果のDFを入れるリスト
  
  for (statname in statnames)
    {
    # 集計
    result = groupby_hour %>% summarise_all(statname)
    cols = names(result)
    cols = cols[cols != "hour"]
  
    # 列名を作る関数
    mergeColStatName = function(colnames, statname)
      {
      newcolnames = NULL
      for (col in colnames)
        {
        newcol = paste(col, statname, sep = "_")
        newcolnames = append(newcolnames, newcol)
        }
       return(newcolnames)
      }
  
    # 集計結果の列名の変更
    newcols = mapply(mergeColStatName, cols, statname)
    newcols = append("hour", newcols)
    # print(newcols)
    colnames(result) = newcols
    results = append(results, result)
    }
  
  results = data.frame(results)
  results = select(results, -matches("hour.+"))
  
  return(results)
}


results = extractFeaturesByHour(data_test, statnames = c("mean","max"), date = "date")
# 参考 #
# summariseの使いかた  http://bcl.sci.yamaguchi-u.ac.jp/~jun/notebook/r/tidyverse/dplyr/

