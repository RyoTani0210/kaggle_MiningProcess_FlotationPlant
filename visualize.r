

rawdata = read.csv("../MiningProcess_Flotation_Plant_Database.csv",sep=",", dec=",")

data = rawdata
data$date = as.POSIXct(data$date, format="%Y-%m-%d %H:%M:%S")


###### ヒストグラム
library(reshape2)
d = melt(rawdata[,-c(1)])

### 
d1 = melt(rawdata[,2:8])
ggplot(d1,aes(x=value)) + facet_wrap(~variable,scales ="free_x",ncol = 1) + geom_histogram() + scale_y_continuous(breaks = c(100000,200000,300000,400000),limits=c(0,500000))

## Floatation Column 1-7 Air Flow
d2 = melt(rawdata[,9:15])
ggplot(d2,aes(x=value)) + facet_wrap(~variable,scales ="free_x",ncol = 1) + geom_histogram() + scale_y_continuous(breaks = c(100000,200000,300000,400000),limits=c(0,500000))

## Floatation Column 1-7 Level
d3 = melt(rawdata[,16:22])
ggplot(d3,aes(x=value)) + facet_wrap(~variable,scales ="free_x",ncol = 1) + geom_histogram() + scale_y_continuous(breaks = c(100000,200000,300000,400000),limits=c(0,500000))

## Floatation Column 1-7 Level
d4 = melt(rawdata[,23:24])
ggplot(d4,aes(x=value)) + facet_wrap(~variable,scales ="free_x",ncol = 1) + geom_histogram() + scale_y_continuous(breaks = c(100000,200000,300000,400000),limits=c(0,500000))

##### タイムスタンプの確認
library(dplyr)
# timestamp別カウント
group_by(data,date)
ts_count = count(data,date)

## timestamp別カウントから、イレギュラーログと思われる時刻を抽出
ts_irregular = dplyr::filter(ts_count, n!="180")

## グラフ化
library(ggplot2)
library(scales)
g = ggplot(ts_count,aes(x=date,y=n)) + geom_line() +
    scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S"), date_breaks = "7 days") + 
    theme(axis.text.x = element_text(angle=60,hjust=1))
plot(g)

## timestamp間隔
ts_interval = ts_count %>% dplyr::mutate(lag=date-lag(date)) 

g = ggplot(ts_interval,aes(x=date,y=lag)) + geom_line() +
  scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M:%S"), date_breaks = "7 days") + 
  theme(axis.text.x = element_text(angle=60,hjust=1))
plot(g)

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

# 推移の確認
## 関数

viewTSShift = function(df,date,filename="graph.pdf"){
  df = melt(df,id.vars = c(date))
  g = ggplot(df,aes(x=date,y=value)) + facet_wrap(~variable,ncol=2,nrow=5, drop=FALSE, scales = "free") + geom_line() +
    scale_x_datetime(labels = date_format("%Y-%m-%d %H:%M"), date_breaks = "28 days") + 
    theme(axis.text.x = element_text(angle=60,hjust=1))
  plot(g)
  ggsave(filename, plot = g, units="mm", width=210, height=297,dpi=100)
  }

viewTSShift(data[1:7],"date",filename ="bbb.png")

### 出力容量の問題で、Rでグラフ出力をあきらめた

write.csv(data, file="data_fixTimestamp.csv")














