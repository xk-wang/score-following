function spectrum = spectrumOfFolder(wavFolder,fs,frameSize,hopSize,wname,fftSize)
% spectrumOfFolder 对文件夹中各wav文件计算STFT振幅谱，保存为mat文件
% spectrum = spectrumOfFolder(wavFolder,fs,frameSize,hopSize,wname,fftSize)
% Outputs:
%  spectrum     cell(1,nWav),顺序为遍历文件夹中wav文件的顺序

wavs = dir([wavFolder,'/*.wav']);
nWav = length(wavs);
spectrum = cell(1,nWav);
for iWav = 1:nWav
    x = preProcessing([wavFolder,'\',wavs(iWav).name],fs);
    spectrum{iWav} = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize);
end
save('spectrum.mat','spectrum');
end