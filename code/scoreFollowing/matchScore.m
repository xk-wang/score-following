function [matching,path] = matchScore(pitches,scoreEvent)
% matchScore ����δȷ����λ���������������ȫ�׸�λ�õ�ƥ��̶ȣ���Ѱ����ȫƥ���·��
%
% [matching,path] = matchScore(pitches,scoreEvent)
%
% Inputs:
%  pitches      δȷ����λ����������������������
%  scoreEvent   ���ף��ṹ��midiToEvent
%
% Outputs:
%  matching     δȷ����λ��������ȫ�׸�λ�õ�ƥ��̶�
%  path         δȷ����λ��������ȫ����ȫƥ���·��

nEvent = length(pitches);
matching = cell(1,nEvent);
for iEvent = 1:nEvent
    performancePitches = pitches{iEvent};
    matching{iEvent} = arrayfun(@(x) matchIEvent(performancePitches,mod(performancePitches,12),length(performancePitches),scoreEvent,x),(1:size(scoreEvent,1))');
end

path = cell(0);
pathEnd = find(matching{nEvent}==1);
for iPath = 1:length(pathEnd)
    path = traceback(pathEnd(iPath),matching,nEvent,path);
end
end

function path = traceback(pathEnd,matching,iCol,path)
% ��iCol������event��Ӧ��pathEnd������event
if iCol<2
    path{1,end+1}(1) = pathEnd;
    return
end
%iEventCandidate = min(pathEnd+2,length(matching{1})):-1:max(pathEnd-2,1);
iEventCandidate = pathEnd:-1:max(pathEnd-2,1);  %path ������ص�
thisPathEnd = iEventCandidate(matching{iCol-1}(iEventCandidate)==1);
if isempty(thisPathEnd)
    path{1,end+1}(1) = pathEnd;
else
    for iPath = 1:length(thisPathEnd)
        nPathPre = size(path,2);
        path = traceback(thisPathEnd(iPath),matching,iCol-1,path);
        nPathNow = size(path,2);
        for jPath = nPathPre+1:nPathNow
            path{1,jPath}(end+1,1) = pathEnd;
        end
    end
end
end