function [isSureFlag,iEvent] = isSure(candidate,minNMatch,iEventPre,barFirst)
% isSure ��֪δȷ����λ������ ������������ȫƥ���·�����Ƿ���ȷ����ǰ�����λ��
%
% [isSureFlag,iEvent] = isSure(candidate,minNMatch,iEventPre)
%
% Inputs:
%  candidate    ��ѡ��Ϣ
%  minNMatch    ȷ����λʱ�� ·������>=minNMatch
%  iEventPre    ��һ�����ࣨ���ܣ��Ķ�λ��matching�е����ֵ��
%
% Outputs:
%  isSureFlag   ��ǰ����Ķ�λ�Ƿ�ȷ��
%  iEvent       ��ǰ���ࣨ���ܣ��Ķ�λ��matching�е����ֵ��

%% ·������>=minNMatch
lPath = cellfun(@numel,candidate.path);
iPath = (lPath>=minNMatch);
pathEnd = unique(cellfun(@(x) x(end),candidate.path(iPath)));
if any(iPath) && length(pathEnd)==1 %����Ҫ���·�����յ�ֻ��һ��
    isSureFlag = 1;
    % pathEnd = unique(cellfun(@(x) x(end),candidate.path(iPath)));
    % if length(pathEnd)>1
    %     isForwardFlag = cellfun(@(x) isForward(x),candidate.path(iPath));
    %     pathEnd = unique(cellfun(@(x) x(end),candidate.path(iPath(isForwardFlag))));
    % end
    % if length(pathEnd)>1 %���յ��ж����ȡ��iEventPre�������iEventPre֮���λ��
    %     distance = abs(pathEnd-iEventPre);
    %     pathEnd = pathEnd(distance==min(distance));
    %     pathEnd = pathEnd(end);
    % end
    iEvent = pathEnd;
else
    %% ��ȷ����λʱ��ȡiEventPre��iEventPre+1��ƥ��̶Ƚϸߵ�λ�ã�����ͬ��ȡiEventPre+1
    isSureFlag = 0;
    if iEventPre<length(candidate.matching{end}) && candidate.matching{end}(iEventPre+1) >= candidate.matching{end}(iEventPre)
        iEvent = iEventPre+1;
    else
        iEvent = iEventPre;
    end
    iEvent = iEvent+barFirst-1;
end
end

% function isForwardFlag = isForward(path)
% isForwardFlag = true;
% for i = 1:length(path)-1
%     diff = path(i+1)-path(i);
%     if diff<0 || diff>1
%         isForwardFlag = false;
%         break;
%     end
% end
% end