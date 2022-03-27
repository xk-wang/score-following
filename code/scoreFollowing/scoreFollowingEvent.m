function [iEvent,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(performancePitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed)
% scoreFollowingEvent �����������������Ӧ�������е�λ��
%
% [iEvent,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(performancePitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed)
%
% Inputs:
%  performancePitches   ������
%  scoreEvent           ���ף��ṹ��midiToEvent
%  iEventPre            ��һ����λ
%  isSureFlag           ��λ�Ƿ�ȷ��
%  candidate            ��ѡ��Ϣ
%  isPlayed             ��һ��λ��Ӧ�������Ƿ�����

global JPITCHES JBARFIRST
nEventBack = 2; %�ֲ�ƥ��ʱ�����Ŀ��ܵ�λ��ΪiEventLastSure+nEventBack*nNotSure

nPerformance = length(performancePitches);
performanceOctave = mod(performancePitches,12);
isSureFlagPre = isSureFlag;

%% ����һ��event��ȷ����λ
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

%% ����ȷ����λ
if ~isSureFlag
    candidate.pitches{end+1} = performancePitches;  %candidate.pitches cell(1,nNotSure),cell�ڣ�������
    nNotSure = length(candidate.pitches);
    iEventLastSure = candidate.iEventLastSure;
    barFirst = scoreEvent{iEventLastSure,JBARFIRST};
    
    candidate.matching{end+1} = arrayfun(@(x) matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,x),(barFirst:min(iEventLastSure+nEventBack*nNotSure,size(scoreEvent,1)))');
    candidate.path = updatePath(candidate.path,find(candidate.matching{end}==1));    %candidate.xxpath cell(1,·����),cell�ڣ�������
    [isSureFlag,iEvent] = isSure(candidate,2,iEventPre-barFirst+1,barFirst);
    
    if isSureFlag
        iEvent = findPath(candidate,iEvent,barFirst);
    end
end

%% �����޸�isPlayed��
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
%�ж�����������ǲ��������е�iEvent��event
global JPITCHES
[lia,locb] = ismember(performancePitches,scoreEvent{iEvent,JPITCHES});
if ~all(lia)
    iEvent = [];
end
end