function path = updatePath(path,newNode)
% updatePath ��newNode����path
% path = updatePath(path,newNode)
% path      ��ǰδȷ����λ��������������ȫƥ���·��
% newNode   �������������������ȫƥ��Ŀ��ܵ�λ��

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