function iEvent = findPath(candidate,pathEnd,barFirst)
% findPath 当前演奏确定定位为pathEnd，对于此前未确定定位的演奏，计算匹配程度最高的路径（绝对值）
%
% iEvent = findPath(candidate,pathEnd)
%
% Inputs:
%  candidate    候选信息
%  pathEnd      当前演奏的确定定位（相对值，候选值序号）

isFullMatch = cellfun(@numel,candidate.path)==length(candidate.pitches); %是否有所有event都匹配的路径
if any(isFullMatch)
    iEvent = cell2mat(candidate.path(isFullMatch));
else
    iEvent = dp(candidate.matching,pathEnd);
end
iEvent = iEvent+barFirst-1;
iEvent = postProcessingIEvent(iEvent,candidate);
end