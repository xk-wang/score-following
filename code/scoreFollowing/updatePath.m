function path = updatePath(path,newNode)
% updatePath 用newNode更新path
% path = updatePath(path,newNode)
% path      此前未确定定位的演奏与乐谱完全匹配的路径
% newNode   新演奏的音符与乐谱完全匹配的可能的位置

if isempty(newNode)
    path = cell(0);
else
    notMatched = true(size(newNode));
    nPath = length(path);
    for iPath = 1:nPath
        pathEnd = path{iPath}(end);
        [isContinue,locb] = ismember([pathEnd,pathEnd+1,pathEnd+2],newNode);
        if any(isContinue)
            iEventContinue = newNode(locb(isContinue));
            notMatched(locb(isContinue))=false;
            for i = 1:sum(isContinue)
                path{1,end+1} = [path{iPath};iEventContinue(i)];
            end
        end
    end
    path(1:nPath) = [];
    path(end+1:end+sum(notMatched)) = num2cell(newNode(notMatched)');
end
end