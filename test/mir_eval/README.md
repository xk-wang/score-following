## 功能

验证../../code/evaluate中evaluation metrics的计算方法是否与MIREX标准一致

## 使用方法

分别运行testEvaluateCode.m、testEvaluateCode.py，对比result文件夹中result.mat与python运行的命令行窗口内对应项的值。

## 运行要求

+	安装mir_eval http://craffel.github.io/mir_eval/

+   Data文件夹中有多音调检测结果和转录结果

	pianoRoll.mat、pianoRollGt.mat：存有同名变量，分别为pianoRoll格式多音调检测结果及ground truth。pianoRoll格式中，第i行对应的音符的MIDI pitch为(i+20)（MIDI pitch 60 --> C4 = middle C），对应的频率为440*2.^((i+20-69)/12)；第j列对应的中间时刻为(j-1)*timeResolution（相应地，testEvaluateCode.m中，对变量timeResolution赋值）。

	midi.mat、midiGt.mat：存有同名变量，分别为midi格式转录结果及ground truth。midi格式为3列的矩阵，第1-3列分别表示MIDI pitch - onset(s) - offset(s)，MIDI pitch i对应的频率为440*2.^((i+20-69)/12)。

+	testEvaluateCode.m中变量onsetTolerance 与 testEvaluateCode.py中变量onset_tolerance 值相同