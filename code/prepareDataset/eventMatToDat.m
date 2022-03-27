function eventMatToDat(folder,destination)
% eventMatToDat 将folder文件夹中的event .mat文件以同名.dat文件存入destination文件夹
% eventMatToDat(folder,destination)
% 若destination文件夹不存在则创建

if exist(folder,'dir')==0
    error('event mat所在的文件夹不存在');
end

% 若destination文件夹不存在则创建
if exist(destination,'dir')==0
    mkdir(destination);
end

events = dir([folder,'/*.mat']);
for iEvent = 1:length(events)
    scoreName = events(iEvent).name;
    load([folder,'\',scoreName]);
    [nRow,nCol] = size(event);
    
    fileID = fopen([destination,'\',scoreName(1:end-4),'.dat'],'w');
    % 将event的第一列打印成第一行
    for iRow = 1:nRow
        fprintf(fileID, '%f ', event{iRow,1});
    end
    % 先切换到下一行，然后空一行
    fprintf(fileID, '\n\n');
    % 后面的每列顺序打印
    for iCol = 2:nCol
        for iRow = 1:nRow
            nRowCell = size(event{iRow,iCol},1);
            for iRowCell = 1:nRowCell
                fprintf(fileID, '%d\t', event{iRow,iCol}(iRowCell));
            end
            fprintf(fileID, '\n');
        end
        fprintf(fileID, '\n');
    end
    fclose(fileID);
end
end