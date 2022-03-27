function result = computeAccuracyFrameLevel(pianoRoll,pianoRollGt,ignoreOctaveErrorsFlag)
% computeAccuracyFrameLevel ����frame-level evaluation metrics
% ���ֵ��ο�ֵƥ��ʱ����һ��һ
%
% result = computeAccuracyFrameLevel(pianoRoll,pianoRollGt,ignoreOctaveErrorsFlag)
%
% Inputs:
%  pianoRoll                �����������
%  pianoRollGt              ground truth
%  ignoreOctaveErrorsFlag   �Ƿ���Ա�Ƶ����1�����ԡ�������������
%  Ҫ��pianoRoll��pianoRollGt������ͬ�����ж�Ӧ��������ͬ�����ж�Ӧ��ʱ����ͬ��
%       ����Ҫ��������ͬ��Ĭ��pianoRoll��ʽ��������ʱ�������������ࣩ��
%       ���Ա�Ƶ����ʱ��pianoRoll��ʽ�У��к����12���ж�Ӧ������Ϊ�˶ȹ�ϵ
%
% Outputs:
%  result   table�����ֶηֱ��ʾ��
%       ��1��nRef         �ο���������
%       ��2��nTot         ת¼�õ�����������
%       ��3��nCorr        ת¼��ȷ����������
%       ��4��nFalsePos    false positives��Ŀ
%       ��5��nFalseNeg    false negatives��Ŀ
%       ��6-9��recall��precision��F-Measure��accuracy
%
% ��https://github.com/craffel/mir_eval/blob/master/mir_eval/multipitch.py���һ��
%
% Nan Yang 2016-07-29 ��֤��������Ϸ��ԣ�������ֵ����������������Ϊtable�����ڵ��ã�
%                     ��Ҫ��pianoRoll��pianoRollGt������ͬ�����Ա�Ƶ����ʱ��������������ͨ�ú���

% ��֤��������Ϸ���
if size(pianoRoll,1) ~= size(pianoRollGt,1)
    error('pianoRoll��ʽ�������������ground truth������һ��');
end

result = table;
result.nRref = sum(sum(pianoRollGt));  %length(find(pianoRollGt==1));��ͼ����ٶȽϿ�
result.nTot = sum(sum(pianoRoll));     %length(find(pianoRoll==1));

nCol = min(size(pianoRoll,2),size(pianoRollGt,2));
if ignoreOctaveErrorsFlag == 1  %���Ա�Ƶ����ʱ
    nNoteOctave = 12;   %pianoRoll��ʽ�У��к����12���ж�Ӧ������Ϊ�˶ȹ�ϵ
    pianoRollChroma = interlacedSum(pianoRoll,nNoteOctave);
    pianoRollGtChroma = interlacedSum(pianoRollGt,nNoteOctave);
    result.nCorr = sum(sum(min(pianoRollChroma(:,1:nCol),pianoRollGtChroma(:,1:nCol))));
else    %�����Ա�Ƶ����ʱ
    result.nCorr = length(find(pianoRoll(:,1:nCol).*pianoRollGt(:,1:nCol)==1));
end

metrics = computeAccuracy(result.nRref, result.nTot, result.nCorr);
result = [result,metrics];
end

function Y = interlacedSum(X,nRow)
% interlacedSum �������
%
% Inputs:
%  X    ���������
%  nRow ÿ��nRow�����
%
% Outputs:
%  Y    nRow�У�������X������ͬ

Y = zeros(nRow,size(X,2));

% for iRow = 1:nRow
%     Y(iRow,:)=sum(X(iRow:nRow:end,:));
% end

nRowX = size(X,1);
for k = 1:nRowX/nRow
    Y = Y + X((k-1)*nRow+1:k*nRow,:);
end
Y(1:nRowX-k*nRow,:) = Y(1:nRowX-k*nRow,:) + X(k*nRow+1:end,:);
end