function [matching,path] = matchScore(pitches,scoreEvent)
% matchScore 计算未确定定位的新演奏的音符与全谱各位置的匹配程度，并寻找完全匹配的路径
%
% [matching,path] = matchScore(pitches,scoreEvent)
%
% Inputs:
%  pitches      未确定定位的新演奏的音符的音符序号
%  scoreEvent   乐谱，结构见midiToEvent
%
% Outputs:
%  matching     未确定定位的演奏与全谱各位置的匹配程度
%  path         未确定定位的演奏与全谱完全匹配的路径

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
% 第iCol个演奏event对应第pathEnd个乐谱event
if iCol<2
    path{1,end+1}(1) = pathEnd;
    return
end
%iEventCandidate = min(pathEnd+2,length(matching{1})):-1:max(pathEnd-2,1);
iEventCandidate = pathEnd:-1:max(pathEnd-2,1);  %path 不允许回弹
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