
rawdata = read.csv("../MiningProcess_Flotation_Plant_Database.csv",sep=",", dec=",")

data = rawdata
data$date = as.POSIXct(data$date, format="%Y-%m-%d %H:%M:%S")

##### timestampの補完
## 分以下の補完　-> 20秒間隔ログとみなして補完する
## ログのない期間
### 2017-03-16 5:00~03-29 12:00  -> 補完をあきらめる
### 2017-04-10 00:00 -> 必要なら補完する


## 分以下の補完
# 20秒間隔定期レコードを作る
tstamp_min = min(data$date)
tstamp_max = max(data$date) + 60*60 - 20 # タイムスタンプが20秒間隔になるように、最後の値を調整する
date_fix = seq(tstamp_min, tstamp_max,by="20 sec")
# 存在しないtimestampを除外する
# 先頭のtimestampのレコード数(174件)に合わせるために、先頭から6レコードを除外する
date_fix1 = date_fix[-c(1:6)]
# 2017-04-10 00:00 のレコード数(179件)に合わせるために、このtimestampの最後のレコード(2017-04-10 00:59:40)を除外する
date_fix2 = date_fix1[date_fix1 != as.POSIXct("2017-04-10 00:59:40")]

# 欠測期間を除外する(2017-03-16 06:00:00 ~ 2017-03-29 12:00:00)
date_fix3 = date_fix2[(date_fix2 < as.POSIXct("2017-03-16 06:00:00")) | (date_fix2 >= as.POSIXct("2017-03-29 12:00:00"))]

#　一致確認
length(date_fix3) - nrow(data)

# dateを置換える
data$date = date_fix3

###### 完全定期レコード化処理
#######  欠落レコードの追加

# 欠落タイムスタンプ
date_lost = c(as.POSIXct("2017-04-10 00:59:40"))
date_lost = append(date_lost, date_fix[(date_fix2 >= as.POSIXct("2017-03-16 06:00:00")) & (date_fix2 < as.POSIXct("2017-03-29 12:00:00"))])

# 行数一致確認
nrow(data) + length(date_lost) == length(date_fix1)


# データフレームをつくって結合する
# 列名 
columns = names(data)
columns = append(columns,"record_losted")

#　欠落レコード
data_lost = data.frame(date = date_lost, record_losted = rep(1, length(date_lost)))


# ログありレコード
data = cbind(data,data.frame(record_losted=as.numeric(rep(0,nrow(data)))))

# 結合
data_fixed = merge(data,data_lost, all=T)
data_fixed = data_fixed[order(data_fixed$date), ]

# tsオブジェクト化
library(xts)
ts_fixed = xts(read.zoo(data_fixed))

### オブジェクトの保存
# xtsオブジェクト
saveRDS(ts_fixed, file = "ts_fixed.obj")
# データフレーム
saveRDS(data_fixed, file = "df_fixed.obj")







