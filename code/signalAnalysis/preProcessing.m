function x = preProcessing(wavPath,fs)
% preProcessing 解析wav，得到单声道、采样频率为fs的采样数据
% 若音频为多声道，取各声道均值。若音频的采样频率非fs，重采样
%
% x = preProcessing(wavPath,fs)
%
% Inputs:
%  wavPath  音频路径
%  fs       采样频率
%
% Outputs:
%  x    单声道、采样频率为fs的采样数据
%
% 参考: https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription/repository/entry/computeCQT.m (by E. Benetos)

[x,fsOriginal] = audioread(wavPath);
%% 若音频为多声道，取各声道均值
if size(x,2)>1
    x = mean(x,2);
end

%% 若音频的采样频率非fs，重采样
if fsOriginal ~= fs
    x = resample(x,fs,fsOriginal);
end
end