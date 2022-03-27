function result = computePrecisionFrameLevel(sfResult,sfResultGt,nFrame,timeResolution,onsetTolerance)
% computePrecisionFrameLevel 计算乐谱跟踪frame level precision
%
% Inputs:
%  sfResult         矩阵，3列，onset - 音符 - 对应于乐谱中的位置
%  sfResultGt       cell，2列，onset - 对应于乐谱中的位置（可能多个，不确定时为[]）
%  nFrame           wav文件对应的总帧数
%  timeResolution   连续两帧的时间差（s）
%  onsetTolerance   转录得到的音符与参考音符匹配时，onset允许偏差（s）(<=)
%
% Outputs:
%  result   table，各字段分别表示：
%       （1）nRef     MIDI文件中音符的总个数
%       （2）nCorr    定位正确的音符总数
%       （3）precision

result = table;
result.nRef = nFrame;
result.nCorr = 0;
for iFrame = 1:nFrame
    tFrame = (iFrame-1)*timeResolution;
    
    tSfResult = sfResult(find(sfResult(:,1)<=tFrame+1e-3,1,'last'),1);
    thisSfResult = sfResult(sfResult(:,1)==tSfResult,3);
    
    iEvent = unique([find(abs(cell2mat(sfResultGt(:,1))-tFrame)<=onsetTolerance);find(cell2mat(sfResultGt(:,1))<=tFrame+1e-3,1,'last')]);
    thisSfResultGt = [];
    for iIEvent = 1:length(iEvent)
        thisSfResultGt = [thisSfResultGt;sfResultGt{iEvent(iIEvent),2}];
    end
    
    if isempty(thisSfResultGt)
        result.nRef = result.nRef-1;
    elseif all(ismember(thisSfResult,thisSfResultGt))
        result.nCorr = result.nCorr+1;
    end
end
result.precision = result.nCorr/result.nRef;
end