function computeTemplate(isolPath,silenceDetection,frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateAll �������е�Ƶ��ģ�塣
%
% e.g. computeTemplate('..\Dataset\realWorldTest\ISOL\PC',0,4096, 441, @hamming, 4096, 0.6, 15);
%
% Inputs:
%  isolWavPath      ����������Ƶ�����ļ���·��
%
% Outputs:          'template.mat'
%  noteList         ��������MIDI pitch
%  templateAll      ����������ģ��
%
% Ҫ�󣺹���������ƵͬĿ¼��������ͬ����mat�ļ����洢timeInfo��
% �򻯣����޶�����������Ƶ�б������88�����������ɾ��noteList��������templateAllΪ����
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

%% ���뾲���ε�Ƶ��ģ��

%% ��template����Ϊ.mat�ļ�
save('template.mat','noteList','template');
end

function [noteList,template] = computeTemplateOneSet(wavPath,timeInfo,silenceDetection,frameSize,hopSize,wname,fftSize,beta,niter)
% computeTemplateOneSet �����������࣬��������ͣ�٣���ȡ��������Ƶ��ģ�塣
%
% Inputs:
%  wavPath          ����Ĺ�����������Ƶ·��
%  midi             ������˳�򣬸�������MIDI pitch - onset time(s) - offset time(s)
%  silenceDetection �Ƿ���Ҫ������⡣��midi�и���������ֹʱ���ڰ��������Σ�����Ҫ�������
%
% Outputs:
%  noteList         ��������MIDI pitch
%  template         ����������ģ��
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
    [template(:,iNote),~,~,~] = nmf_beta(spectrum,1,'beta',beta,'niter',niter,'thresh',eps);   %thresh=eps�����������ܼ������ʱ��ֹͣ
    template(:,iNote) = template(:,iNote)/sum(template(:,iNote)); %ģ���һ��
end
end