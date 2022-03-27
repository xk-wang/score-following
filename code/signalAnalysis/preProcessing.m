function x = preProcessing(wavPath,fs)
% preProcessing ����wav���õ�������������Ƶ��Ϊfs�Ĳ�������
% ����ƵΪ��������ȡ��������ֵ������Ƶ�Ĳ���Ƶ�ʷ�fs���ز���
%
% x = preProcessing(wavPath,fs)
%
% Inputs:
%  wavPath  ��Ƶ·��
%  fs       ����Ƶ��
%
% Outputs:
%  x    ������������Ƶ��Ϊfs�Ĳ�������
%
% �ο�: https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription/repository/entry/computeCQT.m (by E. Benetos)

[x,fsOriginal] = audioread(wavPath);
%% ����ƵΪ��������ȡ��������ֵ
if size(x,2)>1
    x = mean(x,2);
end

%% ����Ƶ�Ĳ���Ƶ�ʷ�fs���ز���
if fsOriginal ~= fs
    x = resample(x,fs,fsOriginal);
end
end