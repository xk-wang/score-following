function computeTemplate(isolPath,frameSize,hopSize,wname,fftSize,beta,niter,silenceDetectionFlag,timeInfo,silenceTemplateFlag,filePath)
% computeTemplate 计算各孤立音符的STFT频谱模板（前半段，floor(fftSize/2)+1），保存至filePath，一列对应一个音符，每一列元素和为1
%
% computeTemplate(isolPath,frameSize,hopSize,wname,fftSize,beta,niter,silenceDetectionFlag,timeInfo,silenceTemplateFlag,filePath)
%
% Inputs:
%  isolPath             孤立音符数据集的路径
%  frameSize,hopSize,wname,fftSize  spectrumOfSignal参数
%  beta,niter           NMF with beta-divergence算法参数
%  silenceDetectionFlag 是否进行静音检测，1：运行detectSilence.m、2：采用数据集中的MIDI信息、其它：不进行静音检测
%  timeInfo             silenceDetectionFlag=2时，要求输入。取其它值时，可输入[]
%                       一行为一个孤立音符音频的MIDI信息，音频顺序为MATLAB遍历文件的顺序，第1-3列分别表示MIDI pitch - onset(s) - offset(s)
%  silenceTemplateFlag  是否包含静音频谱模板，1：包含，0：不包含
%  filePath             频谱模板保存的路径
%
% Nan Yang 2016-07-27

wavs = dir([isolPath,'/*.wav']);
nTemplate = length(wavs);       %频谱模板总数
template = zeros(floor(fftSize/2)+1,nTemplate);
mIter = zeros(nTemplate,1);    %计算各孤立音符的模板时，NMF迭代的次数
errOfNote = zeros(nTemplate,1);  %各孤立音符，NMF分解得到的W、H合成的频谱与输入频谱的误差
for iWav = 1:nTemplate
    wavPath = [isolPath,'\',wavs(iWav).name];
    [x,fs] = audioread(wavPath);    %此处可验证fs
    x = preProcessing(x);
    
    if silenceDetectionFlag == 1
        [soundStart,soundEnd] = detectSilence(x); %静音检测代码
        x = x(soundStart:soundEnd);
    elseif silenceDetectionFlag == 2
        x = x(ceil(timeInfo(iWav,2)*fs):floor(timeInfo(iWav,3)*fs));    %根据数据集中的MIDI信息，取onset-offset间的一段
    end
    spectrum = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize);
    
    % 计算音符的频谱模板
    [template(:,iWav),~,errs{1},~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);   %thresh=eps：当迭代不能减少误差时，停止
    template(:,iWav) = template(:,iWav)/sum(template(:,iWav)); %模板归一化
    mIter(iWav,1) = size(errs{1},1);
    errOfNote(iWav,1) = errs{1}(end,1);
end
maxNIter = max(mIter);
maxErr = max(errOfNote);
% (silenceDetectionFlag,silenceTemplateFlag) (maxNIter,maxErr) - 20161024
% (2,0)                                      (12,1.0638e+04)
% (2,1)仅提取静音模板时                       (6,462.4697)
% (1,0)                                      (12,5.7238e+03)
% (0,0)                                      (13,1.9731e+04)

if silenceTemplateFlag == 1   %计算静音频谱模板  
    templateSilence = computeTemplateSilence(frameSize,hopSize,wname,fftSize,beta,niter);
    template(:,end+1) = templateSilence;
end

save(filePath,'template');
end

function templateSilence = computeTemplateSilence(frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateSilence 计算静音频谱模板
% 将ENSTDkAm\MUS\MAPS_MUS-bk_xmas1_ENSTDkAm(.wav .txt)复制到..\Dataset\MUS目录下

txtMidiToMat('..\Dataset\MUS','..\Dataset\MUS\midiTxtRead');
wavPath = '..\Dataset\MUS\MAPS_MUS-bk_xmas1_ENSTDkAm.wav';
midiPath = '..\Dataset\MUS\midiTxtRead\MAPS_MUS-bk_xmas1_ENSTDkAm.mat';

%% 读音频，并预处理
[x,fs] = audioread(wavPath);
x = preProcessing(x);

%% 判断各帧是否为静音帧
% 参考convertMidiToPianoRoll
timeResolution = 0.01;  %帧间时间间隔
load(midiPath);
isSilence = ones(1,round(max(midi(:,3))/timeResolution)+1);
for iEvent = 1:size(midi,1)
    onsetFrame = round(midi(iEvent,2)/timeResolution)+1;   %onset对应的帧
    offsetFrame = round(midi(iEvent,3)/timeResolution)+1;  %offset对应的帧
    isSilence(onsetFrame:offsetFrame) = 0;
end

%% 寻找训练音频中的静音段
silenceSwitch = diff([0,isSilence,0]);
silence(:,1) = find(silenceSwitch==1);      %静音段开始帧的序号
silence(:,2) = find(silenceSwitch==-1)-1;   %静音段结束帧的序号
silence(:,3) = silence(:,2)-silence(:,1)+1; %静音段长度（帧）

%% 寻找最长的静音段
[~,longest] = max(silence(2:end,3));  %排除音频开始处的静音段
silenceStart = ceil((silence(longest+1,1)-1)*timeResolution*fs);   %静音段开始的点
silenceEnd = floor((silence(longest+1,2)-1)*timeResolution*fs);    %静音段结束的点
xSilence = x(silenceStart:silenceEnd);

%% 计算静音段的频谱模板
spectrum = spectrumOfSignal(xSilence,frameSize,hopSize,wname,fftSize);
[templateSilence,~,errs{1},~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);
templateSilence = templateSilence/sum(templateSilence);
maxNIter = size(errs{1},1);
maxErr = errs{1}(end,1);
end