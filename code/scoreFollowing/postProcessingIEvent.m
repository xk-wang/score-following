function iEvent = postProcessingIEvent(iEvent,candidate)

iEventLastSure = candidate.iEventLastSure;
%% �����ƥ��·���ж��
if size(iEvent,2)>1
    %% ȡunique event������
    nIEvent = size(iEvent,2);
    uniqueEvent = zeros(nIEvent,1);
    for iCol = 1:nIEvent
        uniqueEvent(iCol) = length(unique([iEventLastSure;iEvent(:,iCol)]));
    end
    % iEvent = iEvent(:,uniqueEvent==max(uniqueEvent));
    [~,iIEvent] = max(uniqueEvent);
    iEvent = iEvent(:,iIEvent);
    
    %% ���������ڵ�λ������ͬ������
    % if size(iEvent,2)>1
    %     nEvent = size(iEvent,1);
    %     isSure = zeros(nEvent,1);   %���������Ƿ�ֻ��Ψһ�Ķ�λ
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

%% Զ�ص�
% if iEvent(1,1)<iEventLastSure
%     iEventPre = iEventLastSure;
%     nEventScore = length()
%     for iPerformance = 1:size(iEvent,1)
%         betterMatch = candidate.matching{iPerformance}(max(iEventPre-2,1):min(iEventPre+2,)>candidate.matching{iPerformance}(iEvent(iPerformance));
%         if 
%     end
%     nIEventPre = find(iEvent(:,1) == iEventPre,1,'last');
% end

%% ���ص���һ��ֻ��һ�����ƥ��·����
% if iEvent([1,2],1) == iEventPre
%     nIEventPre = find(iEvent(:,1) == iEventPre,1,'last');
%     notMatch = find(cellfun(@(x) x~=1, candidate.matching(1,1:nIEventPre)));
%     if isempty(notMatch)
%         % �����׸��ٽ���е�iEventPre��λ��������������3�Σ������������಻ƥ��ģ������Ƿ�ص���ǰ1/2��
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