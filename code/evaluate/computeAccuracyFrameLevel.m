function result = computeAccuracyFrameLevel(pianoRoll,pianoRollGt,ignoreOctaveErrorsFlag)
% computeAccuracyFrameLevel 计算frame-level evaluation metrics
% 检测值与参考值匹配时至多一对一
%
% result = computeAccuracyFrameLevel(pianoRoll,pianoRollGt,ignoreOctaveErrorsFlag)
%
% Inputs:
%  pianoRoll                多音调检测结果
%  pianoRollGt              ground truth
%  ignoreOctaveErrorsFlag   是否忽略倍频错误。1：忽略、其它：不忽略
%  要求：pianoRoll、pianoRollGt行数相同，各行对应的音符相同，各列对应的时间相同，
%       （不要求列数相同，默认pianoRoll格式不包含的时刻无音符被演奏）；
%       忽略倍频错误时，pianoRoll格式中，行号相差12的行对应的音符为八度关系
%
% Outputs:
%  result   table，各字段分别表示：
%       （1）nRef         参考音调总数
%       （2）nTot         转录得到的音调总数
%       （3）nCorr        转录正确的音调总数
%       （4）nFalsePos    false positives数目
%       （5）nFalseNeg    false negatives数目
%       （6-9）recall、precision、F-Measure、accuracy
%
% 与https://github.com/craffel/mir_eval/blob/master/mir_eval/multipitch.py结果一致
%
% Nan Yang 2016-07-29 验证输入参数合法性；将返回值数据类型由向量改为table，便于调用；
%                     不要求pianoRoll、pianoRollGt列数相同；忽略倍频错误时，抽象出隔行求和通用函数

% 验证输入参数合法性
if size(pianoRoll,1) ~= size(pianoRollGt,1)
    error('pianoRoll格式多音调检测结果与ground truth行数不一致');
end

result = table;
result.nRref = sum(sum(pianoRollGt));  %length(find(pianoRollGt==1));求和计算速度较快
result.nTot = sum(sum(pianoRoll));     %length(find(pianoRoll==1));

nCol = min(size(pianoRoll,2),size(pianoRollGt,2));
if ignoreOctaveErrorsFlag == 1  %忽略倍频错误时
    nNoteOctave = 12;   %pianoRoll格式中，行号相差12的行对应的音符为八度关系
    pianoRollChroma = interlacedSum(pianoRoll,nNoteOctave);
    pianoRollGtChroma = interlacedSum(pianoRollGt,nNoteOctave);
    result.nCorr = sum(sum(min(pianoRollChroma(:,1:nCol),pianoRollGtChroma(:,1:nCol))));
else    %不忽略倍频错误时
    result.nCorr = length(find(pianoRoll(:,1:nCol).*pianoRollGt(:,1:nCol)==1));
end

metrics = computeAccuracy(result.nRref, result.nTot, result.nCorr);
result = [result,metrics];
end

function Y = interlacedSum(X,nRow)
% interlacedSum 隔行求和
%
% Inputs:
%  X    矩阵或向量
%  nRow 每隔nRow行求和
%
% Outputs:
%  Y    nRow行，列数与X列数相同

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