function [template,noteList] = computeTemplateWav(wavPath,midiPath,fs,frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateWav 孤立音符连奏，提取各音符的频谱模板
%
% [template,noteList] = computeTemplateWav(wavPath,midiPath,fs,frameSize,hopSize,wname,fftSize,beta,niter)
%
% Inputs:
%  wavPath      孤立音符连奏的音频路径
%  midiPath     音频对应的MIDI数据（midi变量，第1-3列分别表示：音符序号 - onset time(s) - offset time(s)）
%  fs           采样频率
%  frameSize,hopSize,wname,fftSize  spectrumOfSignal参数
%  beta,niter   nmf_beta参数
%
% Outputs:
%  template     各音符的频谱模板
%  noteList     template第i列对应的音符序号为noteList(i)

xWav = preProcessing(wavPath,fs);
load(midiPath);
noteList = midi(:,1);
nNote = size(midi,1);
template = zeros(floor(fftSize/2)+1,nNote);
for iNote = 1:nNote
    onset = ceil(midi(iNote,2)*fs);
    if onset == 0
        onset = 1;
    end
    xNote = xWav(onset:floor(midi(iNote,3)*fs));
    
    spectrum = spectrumOfSignal(xNote,frameSize,hopSize,wname,fftSize);
    [template(:,iNote),~,~,~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);   %thresh=eps：当迭代不能减少误差时，停止
    template(:,iNote) = template(:,iNote)/sum(template(:,iNote)); %模板归一化
end
end