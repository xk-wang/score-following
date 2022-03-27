function [isSureFlag,iEvent] = isSure(candidate,minNMatch,iEventPre,barFirst)
% isSure 已知未确定定位的演奏 及其与乐谱完全匹配的路径，是否能确定当前演奏的位置
%
% [isSureFlag,iEvent] = isSure(candidate,minNMatch,iEventPre)
%
% Inputs:
%  candidate    候选信息
%  minNMatch    确定定位时， 路径长度>=minNMatch
%  iEventPre    上一次演奏（可能）的定位（matching中的相对值）
%
% Outputs:
%  isSureFlag   当前演奏的定位是否确定
%  iEvent       当前演奏（可能）的定位（matching中的相对值）

%% 路径长度>=minNMatch
lPath = cellfun(@numel,candidate.path);
iPath = (lPath>=minNMatch);
pathEnd = unique(cellfun(@(x) x(end),candidate.path(iPath)));
if any(iPath) && length(pathEnd)==1 %满足要求的路径的终点只有一个
    isSureFlag = 1;
    % pathEnd = unique(cellfun(@(x) x(end),candidate.path(iPath)));
    % if length(pathEnd)>1
    %     isForwardFlag = cellfun(@(x) isForward(x),candidate.path(iPath));
    %     pathEnd = unique(cellfun(@(x) x(end),candidate.path(iPath(isForwardFlag))));
    % end
    % if length(pathEnd)>1 %若终点有多个，取距iEventPre最近、在iEventPre之后的位置
    %     distance = abs(pathEnd-iEventPre);
    %     pathEnd = pathEnd(distance==min(distance));
    %     pathEnd = pathEnd(end);
    % end
    iEvent = pathEnd;
else
    %% 不确定定位时，取iEventPre、iEventPre+1中匹配程度较高的位置，若相同，取iEventPre+1
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