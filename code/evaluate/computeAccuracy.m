function metrics = computeAccuracy(nRref, nTot, nCorr)
% computeAccuracy ����evaluation metrics
%
% metrics = computeAccuracy(nRref, nTot, nCorr)
%
% Inputs:
%  nRref    �ο�ֵ����
%  nTot     ���õ���ֵ������
%  nCorr    �����ȷ��ֵ������
%
% Outputs:
%  metrics	table�����ֶηֱ��ʾfalse positives��Ŀ��false negatives��Ŀ��recall��precision��F-Measure��accuracy
%
% �ο�: https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription/repository/entry/computeNoteLevelAccuracy.m (by E. Benetos)
%
% Nan Yang 2016-07-29 ������ֵ����������������Ϊtable

%% Number of false positives, false negatives
nFalsePos = nTot-nCorr;
nFalseNeg = nRref-nCorr;

%% ����evaluation metrics
recall = nCorr/nRref;
precision = nCorr/nTot;
fMeasure = 2*((precision*recall)/(precision+recall));
accuracy = nCorr/(nRref+nTot-nCorr);

metrics = array2table([nFalsePos, nFalseNeg, recall, precision, fMeasure, accuracy]);
metrics.Properties.VariableNames = {'nFalsePos' 'nFalseNeg' 'recall' 'precision' 'fMeasure' 'accuracy'};
end