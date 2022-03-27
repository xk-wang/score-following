function [sfResult,sfResultMat] = scoreFollowingMidi(scoreEvent,performanceMidi,varargin)
% scoreFollowingMidi 乐谱跟踪（midi-to-midi alignment）
%
% [sfResult,sfResultMat] = scoreFollowingMidi(scoreEvent,performanceMidi,varargin)
%
% Inputs:
%  scoreEvent       格式见midiToEvent
%  performanceMidi
%
% Options（以变量名-值对方式输入）:
%  minDurFlag       是否进行最短时长约束 [1]
%  minDur           音符的最短时长约束（s）（>=） [0.06]
%  combineEventFlag 是否合并onset间隔<=minInterval的event [1]
%  minInterval      [0.06]
%
% Outputs:
%  sfResult         乐谱跟踪结果，cell(nEvent,3)，event包含的[onset 音符序号]矩阵 - 是否在当帧确定定位 - 定位
%  sfResultMat      乐谱跟踪结果，矩阵(nNote,3)，onset(s) - 音符序号 - 定位
%
% isPlayed的维度由乐谱决定，实际应用中可存储于数据库中

global JPITCHES JBARFIRST
%% 初始化
[minDurFlag,minDur,combineEventFlag,minInterval] = parse_opt(varargin, 'minDurFlag', 1,'minDur', 0.06, 'combineEventFlag', 1, 'minInterval',0.06);
if minDurFlag
    performanceMidi(performanceMidi(:,3)-performanceMidi(:,2)<minDur,:) = [];
end

sfResult = cell(0);
iNote = 1;
if combineEventFlag
    onsetDiff = [diff(performanceMidi(:,2));minInterval+eps];
    while iNote<=size(performanceMidi,1)
        jNote = iNote+find(onsetDiff(iNote:end)>minInterval,1)-1;
        sfResult{end+1,1} = performanceMidi(iNote:jNote,[2,1]);
        iNote = jNote+1;
    end
else
    while iNote<=size(performanceMidi,1)
        jNote = iNote+find(performanceMidi(iNote+1:end,2)~=performanceMidi(iNote,2),1)-1;
        sfResult{end+1,1} = performanceMidi(iNote:jNote,[2,1]);
        iNote = jNote+1;
    end
end

iEventPre = 1;  %上一个定位
isSureFlag = 1; %当前演奏的定位是否确定
isPlayed = zeros(max(cellfun(@numel,scoreEvent(:,JPITCHES))),1);  %上一定位对应的音符是否被演奏，维度由乐谱决定
% candidate：不确定定位时，定位候选信息
% iEventLastSure：上一确定的定位
% path：完全匹配的路径
% pitches：新演奏的音符
% matching：与乐谱中各位置的匹配程度
candidate = struct('iEventLastSure',{[]},'path',{cell(0)},'pitches',{cell(0)},'matching',{cell(0)});

%% 乐谱跟踪
for iEvent = 1:size(sfResult,1)
    % display(['第',num2str(iEvent),'个event']);
    
    newPitches = unique(sfResult{iEvent,1}(:,2));
    [iEventPre,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(newPitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed);
    
    if iEvent==size(sfResult,1) && ~isSureFlag
        iEventPre = findPath(candidate,[],scoreEvent{candidate.iEventLastSure,JBARFIRST});
    end
    
    sfResult{iEvent,2} = isSureFlag;     %是否在当帧确定定位
    sfResult(iEvent-length(iEventPre)+1:iEvent,3) = num2cell(iEventPre);  %定位
    iEventPre = iEventPre(end);
end
% sfResultMat = offlineCheck(sfResult,scoreEvent);
sfResultMat = [];
end