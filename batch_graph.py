import matplotlib.pyplot as plt
import uuid
import img2pdf
import pandas as pd
import os
import math

### 共通
def splitDF(df):
    """
    データフレームを1ページ分に分割する
    """
    attrs = df.columns

    # indexで分割する
    col_idx = range(len(attrs))
    slice_idx = col_idx[0:len(col_idx):10]
    list_figname_df = [] 

    # 画像ファイル名とデータフレームのセットを作成する
    for idx in slice_idx:
        filename = uuid.uuid1()
        target_idx = col_idx[idx:idx+10]
        target_df = df.iloc[:,target_idx]
        list_figname_df.append([f"{filename}.jpg", target_df])

    return list_figname_df


def mergeImg2PDF(o_path, pathlist):
    with open(o_path,"wb") as f:
        f.write(img2pdf.convert(pathlist))
        f.close()
    
    # jpgファイルを削除する
    for path in pathlist:
        os.remove(path)
    


def writeValueShiftCharts(df, x="date",o_path="ts_chart.pdf"):
    """
    データフレームを受け取り、属性別に折れ線グラフを作成し、pdfファイルを出力する
    グラフ数は1ページに10個
    (前提)折れ線グラフのX軸は、日付時刻型

    入力例：
    writeValueShiftCharts(data, x="date")　x軸の列名を指定する
    writeValueShiftCharts(data)　x軸の列名は、date
    """
    x = df[x]

    list_figname_df = splitDF(df)

    # グラフの配置とサイズ設定
    row = 10; col = 1
    unit_inch = 25.4
    figsize = (210/unit_inch, 297/unit_inch)# A4サイズ

    # ページ単位の処理
    for figname_df in list_figname_df:
        fig, axs = plt.subplots(row, col, sharex="col", figsize=figsize)
        attrs_sep = figname_df[1].columns
        
        # グラフ単位処理
        for idx, attr in enumerate(attrs_sep):
            axs[idx].plot(x, figname_df[1][attr])
            axs[idx].set_title(attr, loc="left")

        fig.tight_layout()

        plt.savefig(figname_df[0])
    
    # jpgファイルから
    pathlist = [figname_df[0] for figname_df in list_figname_df]
    mergeImg2PDF(o_path, pathlist)


def writeValueHists(df, o_path="histograms.pdf"):
    """
    histogramを作成し、pdfファイルを出力する
    グラフ数は1ページに10個
    注意：Datetime型の列は除いて処理する(ValueErrorで処理が停止する)

    入力例：
    writeValueHists(data)
    """

    list_figname_df = splitDF(df)

    # グラフの配置とサイズ設定
    row = 10; col = 1
    unit_inch = 25.4
    figsize = (210/unit_inch, 297/unit_inch)# A4サイズ

    # ページ単位の処理
    for figname_df in list_figname_df:
        fig, axs = plt.subplots(row, col, figsize=figsize)
        attrs_sep = figname_df[1].columns
        
        # グラフ単位処理
        for idx, attr in enumerate(attrs_sep):
            axs[idx].hist(figname_df[1][attr])
            axs[idx].set_title(attr, loc="left")
            

        fig.tight_layout()

        plt.savefig(figname_df[0])
    
    # jpgファイルから
    pathlist = [figname_df[0] for figname_df in list_figname_df]
    mergeImg2PDF(o_path, pathlist)