function matching = matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,iEvent)
% matchIEvent ����������������������е�iEvent��λ�õ�ƥ��̶�
%
% matching = matchIEvent(performancePitches,performanceOctave,nPerformance,scoreEvent,iEvent)
%
% Inputs:
%  performancePitches   ��������������������
%  performanceOctave    �������������������ţ����Ա�Ƶ��[0,11]��
%  nPerformance         ���������������
%  scoreEvent           ���ף��ṹ��midiToEvent
%  iEvent               ������ĳλ�õ����

global JPITCHES JPITCHESOCTAVE
% matching = 0.75*sum(ismember(performancePitches,scoreEvent{iEvent,JPITCHES}))/nPerformance+...
%     0.25*sum(ismember(performanceOctave,scoreEvent{iEvent,JPITCHESOCTAVE}))/nPerformance;

if iEvent<=0
    matching = NaN;
else
    distance = arrayfun(@(x) min(abs(x-scoreEvent{iEvent,JPITCHES})),performancePitches);
    matching = (0.6*sum(arrayfun(@(x) distanceToMatching(x),distance))+...
        0.4*sum(ismember(performanceOctave,scoreEvent{iEvent,JPITCHESOCTAVE})))/nPerformance;
    % ��ȫƥ�䣺1    ����1��0.54    ����2��0.48    ����3��0.36    ��Ƶ��0.4
end
end

function matching = distanceToMatching(distance)
% distanceToMatching ����������ת��Ϊƥ��ĸ���
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