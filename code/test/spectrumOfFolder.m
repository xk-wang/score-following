function spectrum = spectrumOfFolder(wavFolder,fs,frameSize,hopSize,wname,fftSize)
% spectrumOfFolder ���ļ����и�wav�ļ�����STFT����ף�����Ϊmat�ļ�
% spectrum = spectrumOfFolder(wavFolder,fs,frameSize,hopSize,wname,fftSize)
% Outputs:
%  spectrum     cell(1,nWav),˳��Ϊ�����ļ�����wav�ļ���˳��

wavs = dir([wavFolder,'/*.wav']);
nWav = length(wavs);
spectrum = cell(1,nWav);
for iWav = 1:nWav
    x = preProcessing([wavFolder,'\',wavs(iWav).name],fs);
    spectrum{iWav} = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize);
end
save('spectrum.mat','spectrum');
end