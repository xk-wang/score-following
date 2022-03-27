function metrics = computeAccuracy(nRref, nTot, nCorr)
% computeAccuracy 计算evaluation metrics
%
% metrics = computeAccuracy(nRref, nTot, nCorr)
%
% Inputs:
%  nRref    参考值总数
%  nTot     检测得到的值的总数
%  nCorr    检测正确的值的总数
%
% Outputs:
%  metrics	table，各字段分别表示false positives数目、false negatives数目、recall、precision、F-Measure、accuracy
%
% 参考: https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription/repository/entry/computeNoteLevelAccuracy.m (by E. Benetos)
%
% Nan Yang 2016-07-29 将返回值数据类型由向量改为table

%% Number of false positives, false negatives
nFalsePos = nTot-nCorr;
nFalseNeg = nRref-nCorr;

%% 计算evaluation metrics
recall = nCorr/nRref;
precision = nCorr/nTot;
fMeasure = 2*((precision*recall)/(precision+recall));
accuracy = nCorr/(nRref+nTot-nCorr);

metrics = array2table([nFalsePos, nFalseNeg, recall, precision, fMeasure, accuracy]);
metrics.Properties.VariableNames = {'nFalsePos' 'nFalseNeg' 'recall' 'precision' 'fMeasure' 'accuracy'};
end