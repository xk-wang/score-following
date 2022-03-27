function [result,sfResult] = computePrecisionNoteLevel(sfResult,sfResultGt,varargin)
% computePrecisionNoteLevel 计算乐谱跟踪note level precision
%
% Inputs:
%  sfResult     矩阵，3列，onset - 音符 - 对应于乐谱中的位置
%  sfResultGt   cell，2列，onset - 对应于乐谱中的位置（可能多个，不确定时为[]）
%
% Outputs:
%  result   table，各字段分别表示：
%       （1）nRef     MIDI文件中音符的总个数
%       （2）nCorr    定位正确的音符总数
%       （3）precision
%  sfResult 增加了第4列，标志定位是否正确，NaN表示不确定正确定位

sfResult(:,4) = 0;
result = table;
result.nRef = size(sfResult,1);
result.nCorr = 0;
for iNote = 1:result.nRef
    iEvent = find(cell2mat(sfResultGt(:,1))<=sfResult(iNote,1)+1e-3,1,'last');  %因浮点数精度影响
    if isempty(sfResultGt{iEvent,2})
        result.nRef = result.nRef-1;
        sfResult(iNote,4) = NaN;
    elseif ismember(sfResult(iNote,3),sfResultGt{iEvent,2})
        result.nCorr = result.nCorr+1;
        sfResult(iNote,4) = 1;
    end
end
result.precision = result.nCorr/result.nRef;
end