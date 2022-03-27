function computeTemplate(isolPath,silenceDetection,frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateAll 计算所有的频谱模板。
%
% e.g. computeTemplate('..\Dataset\realWorldTest\ISOL\PC',0,4096, 441, @hamming, 4096, 0.6, 15);
%
% Inputs:
%  isolWavPath      孤立音符音频所在文件夹路径
%
% Outputs:          'template.mat'
%  noteList         各音符的MIDI pitch
%  templateAll      各音符的谱模板
%
% 要求：孤立音符音频同目录下有与其同名的mat文件，存储timeInfo；
% 简化：若限定孤立音符音频中必须包含88个音符，则可删除noteList变量，改templateAll为矩阵
%
% Nan Yang 2016

wavs = dir([isolPath,'/*.wav']);
nTemplateSet = length(wavs);
noteList = cell(nTemplateSet,1);
template = cell(1,nTemplateSet);
for iTemplateSet = 1:nTemplateSet
    wavPath = [isolPath,'\',wavs(iTemplateSet).name]; 
    load([wavPath(1:end-4),'.mat']);
    [noteList{iTemplateSet},template{iTemplateSet}] = computeTemplateOneSet(wavPath,midi,silenceDetection,frameSize,hopSize,wname,fftSize,beta,niter);    
end
template = cell2mat(template);

%% 加入静音段的频谱模板

%% 将template保存为.mat文件
save('template.mat','noteList','template');
end

function [noteList,template] = computeTemplateOneSet(wavPath,timeInfo,silenceDetection,frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateOneSet 孤立音符连奏，音符间有停顿，提取各音符的频谱模板。
%
% Inputs:
%  wavPath          连奏的孤立音符的音频路径
%  midi             按演奏顺序，各音符的MIDI pitch - onset time(s) - offset time(s)
%  silenceDetection 是否需要静音检测。若midi中各音符的起止时间内包含静音段，则需要静音检测
%
% Outputs:
%  noteList         各音符的MIDI pitch
%  template         各音符的谱模板
%
% Nan Yang 2016

noteList = timeInfo(:,1);
[xWav,fs] = audioread(wavPath);
xWav = preProcessing(xWav);
nNote = size(timeInfo,1);
template = zeros(fftSize/2+1,nNote);
for iNote = 1:nNote
    onset = ceil(timeInfo(iNote,2)*fs);
    if onset == 0
        onset = 1;
    end
    offset = floor(timeInfo(iNote,3)*fs);
    xNote = xWav(onset:offset);
    
    if silenceDetection
        [soundStart,soundEnd] = detectSilence(xNote);
        xNote = xNote(soundStart:soundEnd);
    end
    
	spectrum = spectrumOfSignal(xNote,frameSize,hopSize,wname,fftSize);
    [template(:,iNote),~,~,~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);   %thresh=eps：当迭代不能减少误差时，停止
    template(:,iNote) = template(:,iNote)/sum(template(:,iNote)); %模板归一化
end
end