function sfResult = midiToMidi(scoreEventPath,performanceMidiPath,varargin)
% midiToMidi 乐谱跟踪（midi-to-midi alignment）
%
% sfResult = midiToMidi(scoreEventPath,performanceMidiPath)
%
% Inputs:
%  scoreEventPath       乐谱数据，文件夹或文件,mat文件中存储event变量
%  performanceMidiPath  演奏数据，文件夹或文件,mat文件中存储midi变量。若乐谱与演奏数据均为文件夹，文件顺序需一一对应
%  varargin             见scoreFollowingMidi
%
% Outputs:
%  sfResult     若演奏数据为文件，sfResult结构见scoreFollowingMidi
%               若为文件夹，则sfResult为两列元胞数组：(1)演奏数据文件名；(2)见scoreFollowingMidi

%% 判断乐谱、演奏数据为文件夹或文件
isDirScore = isdir(scoreEventPath);
isDirPerformance = isdir(performanceMidiPath);

if ~isDirScore
    load(scoreEventPath);
end

if isDirPerformance
    performanceMidiFiles = dir([performanceMidiPath,'/*.mat']);
    nFile = size(performanceMidiFiles,1);
    sfResult = cell(nFile,3);
end

switch isDirScore*10+isDirPerformance
    case 00 %一个乐谱对应一次演奏
        load(performanceMidiPath);
        [sfResult{1},sfResult{2}] = scoreFollowingMidi(event,midi,varargin{:});
    case 01 %一个乐谱对应演奏文件夹
        for iFile = 1:nFile
            performanceName = performanceMidiFiles(iFile).name;
            % display([performanceName,'乐谱跟踪']);  %打印演奏文件名称
            load([performanceMidiPath,'\',performanceName]);
            sfResult{iFile,1} = performanceName;
            [sfResult{iFile,2},sfResult{iFile,3}] = scoreFollowingMidi(event,midi,varargin{:});
        end
    case 11 %乐谱文件夹对应演奏文件夹
        scoreEventFiles = dir([scoreEventPath,'/*.mat']);
        for iFile = 1:nFile
            event = load([scoreEventPath,'\',scoreEventFiles(iFile).name]);
            performanceName = performanceMidiFiles(iFile).name;
            % display([performanceName,'乐谱跟踪']);
            load([performanceMidiPath,'\',performanceName]);
            sfResult{iFile,1} = performanceName;
            [sfResult{iFile,2},sfResult{iFile,3}] = scoreFollowingMidi(event,midi,varargin{:});
        end
    otherwise
        error('一次演奏对应多个乐谱')
end
end