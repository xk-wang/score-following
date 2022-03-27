function sfResult = midiToMidi(scoreEventPath,performanceMidiPath,varargin)
% midiToMidi ���׸��٣�midi-to-midi alignment��
%
% sfResult = midiToMidi(scoreEventPath,performanceMidiPath)
%
% Inputs:
%  scoreEventPath       �������ݣ��ļ��л��ļ�,mat�ļ��д洢event����
%  performanceMidiPath  �������ݣ��ļ��л��ļ�,mat�ļ��д洢midi���������������������ݾ�Ϊ�ļ��У��ļ�˳����һһ��Ӧ
%  varargin             ��scoreFollowingMidi
%
% Outputs:
%  sfResult     ����������Ϊ�ļ���sfResult�ṹ��scoreFollowingMidi
%               ��Ϊ�ļ��У���sfResultΪ����Ԫ�����飺(1)���������ļ�����(2)��scoreFollowingMidi

%% �ж����ס���������Ϊ�ļ��л��ļ�
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
    case 00 %һ�����׶�Ӧһ������
        load(performanceMidiPath);
        [sfResult{1},sfResult{2}] = scoreFollowingMidi(event,midi,varargin{:});
    case 01 %һ�����׶�Ӧ�����ļ���
        for iFile = 1:nFile
            performanceName = performanceMidiFiles(iFile).name;
            % display([performanceName,'���׸���']);  %��ӡ�����ļ�����
            load([performanceMidiPath,'\',performanceName]);
            sfResult{iFile,1} = performanceName;
            [sfResult{iFile,2},sfResult{iFile,3}] = scoreFollowingMidi(event,midi,varargin{:});
        end
    case 11 %�����ļ��ж�Ӧ�����ļ���
        scoreEventFiles = dir([scoreEventPath,'/*.mat']);
        for iFile = 1:nFile
            event = load([scoreEventPath,'\',scoreEventFiles(iFile).name]);
            performanceName = performanceMidiFiles(iFile).name;
            % display([performanceName,'���׸���']);
            load([performanceMidiPath,'\',performanceName]);
            sfResult{iFile,1} = performanceName;
            [sfResult{iFile,2},sfResult{iFile,3}] = scoreFollowingMidi(event,midi,varargin{:});
        end
    otherwise
        error('һ�������Ӧ�������')
end
end