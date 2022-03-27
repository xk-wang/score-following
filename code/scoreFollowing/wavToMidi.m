function sfResult = wavToMidi(scoreEventPath,pianoRoll,timeResolution,varargin)
% wavToMidi ���׸��٣�wav-to-midi alignment��
%
% sfResult = wavToMidi(scoreEventPath,pianoRoll,timeResolution,varargin)
%
% Inputs:
%  scoreEventPath   �������ݣ��ļ��л��ļ�
%  pianoRoll        �����������cell(1,��Ƶ��)��cell�ڽṹ��scoreFollowingWav
%  timeResolution   pianoRoll���������е�ʱ��s��
%  varargin         ��scoreFollowingWav
%
% Outputs:
%  sfResult         cell(nWav,1)��cell�ڽṹ��scoreFollowingWav

%% �ж����ס�������ƵΪ�ļ��л��ļ�
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