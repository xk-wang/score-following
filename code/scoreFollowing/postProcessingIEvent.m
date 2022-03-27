function iEvent = postProcessingIEvent(iEvent,candidate)

iEventLastSure = candidate.iEventLastSure;
%% 若最佳匹配路径有多个
if size(iEvent,2)>1
    %% 取unique event数最多的
    nIEvent = size(iEvent,2);
    uniqueEvent = zeros(nIEvent,1);
    for iCol = 1:nIEvent
        uniqueEvent(iCol) = length(unique([iEventLastSure;iEvent(:,iCol)]));
    end
    % iEvent = iEvent(:,uniqueEvent==max(uniqueEvent));
    [~,iIEvent] = max(uniqueEvent);
    iEvent = iEvent(:,iIEvent);
    
    %% 乐谱中相邻的位置有相同的音符
    % if size(iEvent,2)>1
    %     nEvent = size(iEvent,1);
    %     isSure = zeros(nEvent,1);   %各次演奏是否只有唯一的定位
    %     for iPos = 1:nEvent
    %         isSure(iPos) = all(iEvent(iPos,:)==iEvent(iPos,1));
    %     end
    %     diffIsSure = diff([1,isSure,1]);
    %     notSureStart = find(diffIsSure==-1);
    %     notSureEnd = find(diffIsSure==1)-1;
    %     for iSegment = 1:length(notSureStart)
    %
    %     end
    % end    
end

%% 远回弹
% if iEvent(1,1)<iEventLastSure
%     iEventPre = iEventLastSure;
%     nEventScore = length()
%     for iPerformance = 1:size(iEvent,1)
%         betterMatch = candidate.matching{iPerformance}(max(iEventPre-2,1):min(iEventPre+2,)>candidate.matching{iPerformance}(iEvent(iPerformance));
%         if 
%     end
%     nIEventPre = find(iEvent(:,1) == iEventPre,1,'last');
% end

%% 近回弹（一般只有一条最佳匹配路径）
% if iEvent([1,2],1) == iEventPre
%     nIEventPre = find(iEvent(:,1) == iEventPre,1,'last');
%     notMatch = find(cellfun(@(x) x~=1, candidate.matching(1,1:nIEventPre)));
%     if isempty(notMatch)
%         % 若乐谱跟踪结果中第iEventPre个位置连续出现至少3次，且其中有演奏不匹配的，考虑是否回弹到前1/2个
%         for iPerformance = notMatch(end:-1:1)
%             performancePitches = candidate.pitches{iPerformance};
%             performanceOctave = mod(performancePitches,12);
%             nPerformance = length(performancePitches);
%             matchingPre = matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,iEventPre-1);
%             if matchingPre >
%             end
%         end
%     end
% end
end