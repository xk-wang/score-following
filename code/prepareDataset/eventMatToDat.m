function eventMatToDat(folder,destination)
% eventMatToDat ��folder�ļ����е�event .mat�ļ���ͬ��.dat�ļ�����destination�ļ���
% eventMatToDat(folder,destination)
% ��destination�ļ��в������򴴽�

if exist(folder,'dir')==0
    error('event mat���ڵ��ļ��в�����');
end

% ��destination�ļ��в������򴴽�
if exist(destination,'dir')==0
    mkdir(destination);
end

events = dir([folder,'/*.mat']);
for iEvent = 1:length(events)
    scoreName = events(iEvent).name;
    load([folder,'\',scoreName]);
    [nRow,nCol] = size(event);
    
    fileID = fopen([destination,'\',scoreName(1:end-4),'.dat'],'w');
    % ��event�ĵ�һ�д�ӡ�ɵ�һ��
    for iRow = 1:nRow
        fprintf(fileID, '%f ', event{iRow,1});
    end
    % ���л�����һ�У�Ȼ���һ��
    fprintf(fileID, '\n\n');
    % �����ÿ��˳���ӡ
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