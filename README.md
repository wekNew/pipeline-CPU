# 實作時間
大二上 - 計算機組織
# 摘要
用verilog做出一個pipeline-CPU。
# 功能介紹
大致可以分成五個階段。(讀取階段)將PC儲存指令的位子取到IM並往下傳到(解碼階段)Decoder，將指令分成操作碼、rs位子等並傳送到控制器生成相應的控制訊號，接著(執行階段)將剛才的資料處理並進到ALU和JB unit再進行邏輯運算和判斷跳躍分支指令並計算新的PC位子，隨後(記憶體階段)透過Controller中指令的Lord/Store類別判斷DM為讀取或寫入，並使用LD Filter來處理不同 load-bit(lb/lh/lw/lbu/lhu)的 w_en，最後(寫回階段)， ALU 或資料記憶體的結果會寫回Reg File，更新 rd 寄存器中的資料，完成指令的執行。

主要架構。
![image](https://github.com/user-attachments/assets/b7a2d0e0-6737-4521-a7df-e0fdb6e2fa24)
