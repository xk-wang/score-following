function matching = matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,iEvent)
% matchIEvent 计算新演奏的音符与乐谱中第iEvent个位置的匹配程度
%
% matching = matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,iEvent)
%
% Inputs:
%  performancePitches   新演奏的音符的音符序号
%  performanceOctave    新演奏的音符的音符序号（忽略倍频，[0,11]）
%  nPerformance         新演奏的音符个数
%  scoreEvent           乐谱，结构见midiToEvent
%  iEvent               乐谱中某位置的序号

global JPITCHES JPITCHESOCTAVE
% matching = 0.75*sum(ismember(performancePitches,scoreEvent{iEvent,JPITCHES}))/nPerformance+...
%     0.25*sum(ismember(performanceOctave,scoreEvent{iEvent,JPITCHESOCTAVE}))/nPerformance;

if iEvent<=0
    matching = NaN;
else
    distance = arrayfun(@(x) min(abs(x-scoreEvent{iEvent,JPITCHES})),performancePitches);
    matching = (0.6*sum(arrayfun(@(x) distanceToMatching(x),distance))+...
        0.4*sum(ismember(performanceOctave,scoreEvent{iEvent,JPITCHESOCTAVE})))/nPerformance;
    % 完全匹配：1    距离1：0.54    距离2：0.48    距离3：0.36    倍频：0.4
end
end

function matching = distanceToMatching(distance)
% distanceToMatching 将音调距离转换为匹配的概率
switch distance
    case 0
        matching = 1;
    case 1
        matching = 0.9;
    case 2
        matching = 0.8;
    case 3
        matching = 0.6;
    otherwise
        matching = 0;
end
end