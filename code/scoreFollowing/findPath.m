function iEvent = findPath(candidate,pathEnd,barFirst)
% findPath ��ǰ����ȷ����λΪpathEnd�����ڴ�ǰδȷ����λ�����࣬����ƥ��̶���ߵ�·��������ֵ��
%
% iEvent = findPath(candidate,pathEnd)
%
% Inputs:
%  candidate    ��ѡ��Ϣ
%  pathEnd      ��ǰ�����ȷ����λ�����ֵ����ѡֵ��ţ�

isFullMatch = cellfun(@numel,candidate.path)==length(candidate.pitches); %�Ƿ�������event��ƥ���·��
if any(isFullMatch)
    iEvent = cell2mat(candidate.path(isFullMatch));
else
    iEvent = dp(candidate.matching,pathEnd);
end
iEvent = iEvent+barFirst-1;
iEvent = postProcessingIEvent(iEvent,candidate);
end