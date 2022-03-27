function computeTemplate(isolPath,frameSize,hopSize,wname,fftSize,beta,niter,silenceDetectionFlag,timeInfo,silenceTemplateFlag,filePath)
% computeTemplate ���������������STFTƵ��ģ�壨ǰ��Σ�floor(fftSize/2)+1����������filePath��һ�ж�Ӧһ��������ÿһ��Ԫ�غ�Ϊ1
%
% computeTemplate(isolPath,frameSize,hopSize,wname,fftSize,beta,niter,silenceDetectionFlag,timeInfo,silenceTemplateFlag,filePath)
%
% Inputs:
%  isolPath             �����������ݼ���·��
%  frameSize,hopSize,wname,fftSize  spectrumOfSignal����
%  beta,niter           NMF with beta-divergence�㷨����
%  silenceDetectionFlag �Ƿ���о�����⣬1������detectSilence.m��2���������ݼ��е�MIDI��Ϣ�������������о������
%  timeInfo             silenceDetectionFlag=2ʱ��Ҫ�����롣ȡ����ֵʱ��������[]
%                       һ��Ϊһ������������Ƶ��MIDI��Ϣ����Ƶ˳��ΪMATLAB�����ļ���˳�򣬵�1-3�зֱ��ʾMIDI pitch - onset(s) - offset(s)
%  silenceTemplateFlag  �Ƿ��������Ƶ��ģ�壬1��������0��������
%  filePath             Ƶ��ģ�屣���·��
%
% Nan Yang 2016-07-27

wavs = dir([isolPath,'/*.wav']);
nTemplate = length(wavs);       %Ƶ��ģ������
template = zeros(floor(fftSize/2)+1,nTemplate);
mIter = zeros(nTemplate,1);    %���������������ģ��ʱ��NMF�����Ĵ���
errOfNote = zeros(nTemplate,1);  %������������NMF�ֽ�õ���W��H�ϳɵ�Ƶ��������Ƶ�׵����
for iWav = 1:nTemplate
    wavPath = [isolPath,'\',wavs(iWav).name];
    [x,fs] = audioread(wavPath);    %�˴�����֤fs
    x = preProcessing(x);
    
    if silenceDetectionFlag == 1
        [soundStart,soundEnd] = detectSilence(x); %����������
        x = x(soundStart:soundEnd);
    elseif silenceDetectionFlag == 2
        x = x(ceil(timeInfo(iWav,2)*fs):floor(timeInfo(iWav,3)*fs));    %�������ݼ��е�MIDI��Ϣ��ȡonset-offset���һ��
    end
    spectrum = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize);
    
    % ����������Ƶ��ģ��
    [template(:,iWav),~,errs{1},~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);   %thresh=eps�����������ܼ������ʱ��ֹͣ
    template(:,iWav) = template(:,iWav)/sum(template(:,iWav)); %ģ���һ��
    mIter(iWav,1) = size(errs{1},1);
    errOfNote(iWav,1) = errs{1}(end,1);
end
maxNIter = max(mIter);
maxErr = max(errOfNote);
% (silenceDetectionFlag,silenceTemplateFlag) (maxNIter,maxErr) - 20161024
% (2,0)                                      (12,1.0638e+04)
% (2,1)����ȡ����ģ��ʱ                       (6,462.4697)
% (1,0)                                      (12,5.7238e+03)
% (0,0)                                      (13,1.9731e+04)

if silenceTemplateFlag == 1   %���㾲��Ƶ��ģ��  
    templateSilence = computeTemplateSilence(frameSize,hopSize,wname,fftSize,beta,niter);
    template(:,end+1) = templateSilence;
end

save(filePath,'template');
end

function templateSilence = computeTemplateSilence(frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateSilence ���㾲��Ƶ��ģ��
% ��ENSTDkAm\MUS\MAPS_MUS-bk_xmas1_ENSTDkAm(.wav .txt)���Ƶ�..\Dataset\MUSĿ¼��

txtMidiToMat('..\Dataset\MUS','..\Dataset\MUS\midiTxtRead');
wavPath = '..\Dataset\MUS\MAPS_MUS-bk_xmas1_ENSTDkAm.wav';
midiPath = '..\Dataset\MUS\midiTxtRead\MAPS_MUS-bk_xmas1_ENSTDkAm.mat';

%% ����Ƶ����Ԥ����
[x,fs] = audioread(wavPath);
x = preProcessing(x);

%% �жϸ�֡�Ƿ�Ϊ����֡
% �ο�convertMidiToPianoRoll
timeResolution = 0.01;  %֡��ʱ����
load(midiPath);
isSilence = ones(1,round(max(midi(:,3))/timeResolution)+1);
for iEvent = 1:size(midi,1)
    onsetFrame = round(midi(iEvent,2)/timeResolution)+1;   %onset��Ӧ��֡
    offsetFrame = round(midi(iEvent,3)/timeResolution)+1;  %offset��Ӧ��֡
    isSilence(onsetFrame:offsetFrame) = 0;
end

%% Ѱ��ѵ����Ƶ�еľ�����
silenceSwitch = diff([0,isSilence,0]);
silence(:,1) = find(silenceSwitch==1);      %�����ο�ʼ֡�����
silence(:,2) = find(silenceSwitch==-1)-1;   %�����ν���֡�����
silence(:,3) = silence(:,2)-silence(:,1)+1; %�����γ��ȣ�֡��

%% Ѱ����ľ�����
[~,longest] = max(silence(2:end,3));  %�ų���Ƶ��ʼ���ľ�����
silenceStart = ceil((silence(longest+1,1)-1)*timeResolution*fs);   %�����ο�ʼ�ĵ�
silenceEnd = floor((silence(longest+1,2)-1)*timeResolution*fs);    %�����ν����ĵ�
xSilence = x(silenceStart:silenceEnd);

%% ���㾲���ε�Ƶ��ģ��
spectrum = spectrumOfSignal(xSilence,frameSize,hopSize,wname,fftSize);
[templateSilence,~,errs{1},~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);
templateSilence = templateSilence/sum(templateSilence);
maxNIter = size(errs{1},1);
maxErr = errs{1}(end,1);
end