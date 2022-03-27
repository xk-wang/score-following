function sfResult = wavToMidi(scoreEventPath,pianoRoll,timeResolution,varargin)
% wavToMidi 乐谱跟踪（wav-to-midi alignment）
%
% sfResult = wavToMidi(scoreEventPath,pianoRoll,timeResolution,varargin)
%
% Inputs:
%  scoreEventPath   乐谱数据，文件夹或文件
%  pianoRoll        音调检测结果，cell(1,音频数)，cell内结构见scoreFollowingWav
%  timeResolution   pianoRoll中连续两列的时间差（s）
%  varargin         见scoreFollowingWav
%
% Outputs:
%  sfResult         cell(nWav,1)，cell内结构见scoreFollowingWav

%% 判断乐谱、演奏音频为文件夹或文件
isDirScore = isdir(scoreEventPath);
nWav = size(pianoRoll,2);
sfResult = cell(nWav,2);

if isDirScore
    scoreEventFiles = dir([scoreEventPath,'/*.mat']);
    for iWav = 1:nWav
        load([scoreEventPath,'\',scoreEventFiles(iWav).name]);
        [sfResult{iWav,1},sfResult{iWav,2}] = scoreFollowingWav(event,pianoRoll{iWav},timeResolution,varargin{:});
    end
else
    load(scoreEventPath);
    for iWav = 1:nWav
        [sfResult{iWav,1},sfResult{iWav,2}] = scoreFollowingWav(event,pianoRoll{iWav},timeResolution,varargin{:});
    end
end
end