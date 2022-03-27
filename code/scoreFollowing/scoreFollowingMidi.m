function [sfResult,sfResultMat] = scoreFollowingMidi(scoreEvent,performanceMidi,varargin)
% scoreFollowingMidi ���׸��٣�midi-to-midi alignment��
%
% [sfResult,sfResultMat] = scoreFollowingMidi(scoreEvent,performanceMidi,varargin)
%
% Inputs:
%  scoreEvent       ��ʽ��midiToEvent
%  performanceMidi
%
% Options���Ա�����-ֵ�Է�ʽ���룩:
%  minDurFlag       �Ƿ�������ʱ��Լ�� [1]
%  minDur           ���������ʱ��Լ����s����>=�� [0.06]
%  combineEventFlag �Ƿ�ϲ�onset���<=minInterval��event [1]
%  minInterval      [0.06]
%
% Outputs:
%  sfResult         ���׸��ٽ����cell(nEvent,3)��event������[onset �������]���� - �Ƿ��ڵ�֡ȷ����λ - ��λ
%  sfResultMat      ���׸��ٽ��������(nNote,3)��onset(s) - ������� - ��λ
%
% isPlayed��ά�������׾�����ʵ��Ӧ���пɴ洢�����ݿ���

global JPITCHES JBARFIRST
%% ��ʼ��
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

iEventPre = 1;  %��һ����λ
isSureFlag = 1; %��ǰ����Ķ�λ�Ƿ�ȷ��
isPlayed = zeros(max(cellfun(@numel,scoreEvent(:,JPITCHES))),1);  %��һ��λ��Ӧ�������Ƿ����࣬ά�������׾���
% candidate����ȷ����λʱ����λ��ѡ��Ϣ
% iEventLastSure����һȷ���Ķ�λ
% path����ȫƥ���·��
% pitches�������������
% matching���������и�λ�õ�ƥ��̶�
candidate = struct('iEventLastSure',{[]},'path',{cell(0)},'pitches',{cell(0)},'matching',{cell(0)});

%% ���׸���
for iEvent = 1:size(sfResult,1)
    % display(['��',num2str(iEvent),'��event']);
    
    newPitches = unique(sfResult{iEvent,1}(:,2));
    [iEventPre,isSureFlag,candidate,isPlayed] = scoreFollowingEvent(newPitches,scoreEvent,iEventPre,isSureFlag,candidate,isPlayed);
    
    if iEvent==size(sfResult,1) && ~isSureFlag
        iEventPre = findPath(candidate,[],scoreEvent{candidate.iEventLastSure,JBARFIRST});
    end
    
    sfResult{iEvent,2} = isSureFlag;     %�Ƿ��ڵ�֡ȷ����λ
    sfResult(iEvent-length(iEventPre)+1:iEvent,3) = num2cell(iEventPre);  %��λ
    iEventPre = iEventPre(end);
end
% sfResultMat = offlineCheck(sfResult,scoreEvent);
sfResultMat = [];
end