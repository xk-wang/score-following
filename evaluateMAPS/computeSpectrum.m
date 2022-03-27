function computeSpectrum(wavMusPath,frameSize,hopSize,wname,fftSize)
wavs = dir([wavMusPath,'/*.wav']);
nWav = length(wavs);
spectrum = cell(1,nWav);
nSpectrumFramePerWav = zeros(nWav,1);
for iWav = 1:nWav
    [x,fs] = audioread([wavMusPath,'\',wavs(iWav).name]);  %此处可验证fs
    x = preProcessing(x);
    spectrum{iWav} = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize);
    nSpectrumFramePerWav(iWav) = size(spectrum{iWav},2);
end
spectrumAll = cell2mat(spectrum);
save spectrumAll.mat spectrumAll nSpectrumFramePerWav frameSize hopSize wname fftSize;
end