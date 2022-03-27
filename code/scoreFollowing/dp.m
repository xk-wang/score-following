function iEvent = dp(matching,pathEnd)
nCol = length(matching);
if nCol==1
    iEvent = find(matching{1}==max(matching{1}))';
    return
end

%% degree(i,j)：第i个乐谱event 与 倒数第j个演奏event 的匹配程度
if isempty(pathEnd)
    nRow =  length(matching{end});
    degree = NaN(nRow+2,nCol);
    for iCol = 1:nCol
        degree(1:length(matching{end+1-iCol}),iCol) = matching{end+1-iCol};
    end
else
    nRow = min(pathEnd,length(matching{end-1}));
    degree = NaN(nRow+2,nCol);
    degree(pathEnd,1) = 1;
    for iCol = 2:nCol
        nCandidate = min(nRow,length(matching{end+1-iCol}));
        degree(1:nCandidate,iCol) = matching{end+1-iCol}(1:nCandidate);
    end
end

%% 计算各路径的匹配程度
% degree(i,j)：从pathEnd到(i,j)的最大累积匹配程度
% phi(i,j)：从pathEnd到degree(i,j+1)的方向
phi = cell(nRow,nCol-1);
for iCol = 1:nCol-1
    for iRow = 1:nRow
        DNeighbor = [degree(iRow, iCol), degree(iRow+1, iCol), degree(iRow+2, iCol)];
        dmax = max(DNeighbor);
        tb = find(DNeighbor==dmax);
        degree(iRow,iCol+1) = degree(iRow,iCol+1)+dmax;
        phi{iRow,iCol} = tb;
    end
end

%% Traceback
pathStart = find(degree(:,nCol)==max(degree(:,nCol)));
nPathStart = length(pathStart);
iEvent = cell(1,nPathStart);
for iStart = 1:nPathStart
    iEvent{iStart} = traceback(pathStart(iStart),phi,nCol,nCol,[]);
end
iEvent = cell2mat(iEvent);
end

function iEvent = traceback(pathStart,phi,iCol,nCol,iEvent)
% 第（nCol+1-iCol）个演奏event对应第pathStart个乐谱event
if iCol<2
    iEvent(nCol,end+1) = pathStart;
    return
end
direction = phi{pathStart,iCol-1};
for iDirection = 1:length(direction)
    thisPathStart = pathStart+direction(iDirection)-1;
    nColPre = size(iEvent,2);
    iEvent = traceback(thisPathStart,phi,iCol-1,nCol,iEvent);
    nColNext = size(iEvent,2);
    iEvent(nCol+1-iCol,nColPre+1:nColNext) = pathStart;
end
end