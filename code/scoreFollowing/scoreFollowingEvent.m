function [iEvent,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(performancePitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed)
% scoreFollowingEvent 计算新演奏的音符对应于乐谱中的位置
%
% [iEvent,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(performancePitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed)
%
% Inputs:
%  performancePitches   列向量
%  scoreEvent           乐谱，结构见midiToEvent
%  iEventPre            上一个定位
%  isSureFlag           定位是否确定
%  candidate            候选信息
%  isPlayed             上一定位对应的音符是否被演奏

global JPITCHES JBARFIRST
nEventBack = 2; %局部匹配时，最后的可能的位置为iEventLastSure+nEventBack*nNotSure

nPerformance = length(performancePitches);
performanceOctave = mod(performancePitches,12);
isSureFlagPre = isSureFlag;

%% 若上一个event有确定定位
while isSureFlagPre
    [iEvent,lia,locb] = isIEvent(performancePitches,scoreEvent,iEventPre);
    if ~isempty(iEvent) && ~any(isPlayed(locb))
        break;
    end
    
    if iEventPre<size(scoreEvent,1)
        [iEvent2,Lia2,Locb2] = isIEvent(performancePitches,scoreEvent,iEventPre+1);
        if ~isempty(iEvent2)
            iEvent = iEventPre+1;
            lia = Lia2;
            locb = Locb2;
            break;
        elseif ~isempty(iEvent)
            break;
        end
    end
    
    isSureFlag = 0;
    candidate.iEventLastSure = iEventPre;
    break;
end

%% 若无确定定位
if ~isSureFlag
    candidate.pitches{end+1} = performancePitches;  %candidate.pitches cell(1,nNotSure),cell内，列向量
    nNotSure = length(candidate.pitches);
    iEventLastSure = candidate.iEventLastSure;
    barFirst = scoreEvent{iEventLastSure,JBARFIRST};
    
    candidate.matching{end+1} = arrayfun(@(x) matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,x),(barFirst:min(iEventLastSure+nEventBack*nNotSure,size(scoreEvent,1)))');
    candidate.path = updatePath(candidate.path,find(candidate.matching{end}==1));    %candidate.xxpath cell(1,路径数),cell内，列向量
    [isSureFlag,iEvent] = isSure(candidate,2,iEventPre-barFirst+1,barFirst);
    
    if isSureFlag
        iEvent = findPath(candidate,iEvent,barFirst);
    end
end

%% 后处理（修改isPlayed）
if isSureFlag
    candidate = structfun(@(x) cell(0),candidate,'UniformOutput',false);
    if isSureFlagPre
        if iEvent~=iEventPre
            isPlayed(1:end) = 0;
        end
    else
        [lia,locb] = ismember(performancePitches,scoreEvent{iEvent(end),JPITCHES});
        isPlayed(1:end) = 0;
    end
    isPlayed(locb(lia)) = 1;
end
end

function [iEvent,lia,locb] = isIEvent(performancePitches,scoreEvent,iEvent)
%判断演奏的音符是不是乐谱中第iEvent个event
global JPITCHES
[lia,locb] = ismember(performancePitches,scoreEvent{iEvent,JPITCHES});
if ~all(lia)
    iEvent = [];
end
end