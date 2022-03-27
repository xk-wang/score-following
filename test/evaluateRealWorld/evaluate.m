function evaluate(datasetPath,frameSize,hopSize,wname,fftSize,beta,niter)
% evaluate('..\Dataset\realWorldTest\MUS\PC', 4096, 441, @hamming, 4096, 0.6, 15)

%% ���������·��
addpath('..\Libraries\nmflib');
addpath(genpath('..\code'));

%% �ֱ�Ը�.wav�ļ�����STFT

%% ����ground truth

%% ��NMF with beta-divergence�㷨���ж��������
load('spectrumAll.mat');
load('templatePC.mat');
nTemplate = size(template,2);  %Ƶ��ģ������
nFrameAll = size(spectrumAll,2);
h = zeros(nTemplate,nFrameAll);

%% �����ʼ��

%% ground truth��ʼ��
% �����ʼ���õ���H��Ӧ��Ϊ1/0��activition�ľ�ֵ�ֱ�Ϊ115.5188��0.5984
load('H0Gt264.mat');

% ����ģ�����H0
noteIndex = noteList;   %ģ����������Ӧ��H0������
for iTemplateSet = 1:size(noteIndex,1)
     noteIndex{iTemplateSet} = noteIndex{iTemplateSet}+88*(iTemplateSet-1)-20;
end
noteIndex = cell2mat(noteIndex);
H0Gt = H0Gt(noteIndex,:);

for iFrame = 1:nFrameAll
    if all(spectrumAll(:,iFrame))
        [~,h(:,iFrame),~,~] = nmf_beta(spectrumAll(:,iFrame),nTemplate,'W0',template,'W',template,'H0',H0Gt(:,iFrame),'beta',beta,'niter',niter);
    end
end

%% post processing������
fs = 44100;
newH = formatHTo88Rows(h,noteList{1});  %Ҫ�����ģ��������ͬ
load('gtAll.mat');
[threshChose,fMeasure] = chooseThresh(newH,pianoRollGtAll,midiGtAll);
pianoRoll = double(newH>threshChose);
midi = convertPianoRollToMidi(pianoRoll,hopSize/fs);
resultNoteLevel = computeAccuracyNoteLevel(midi,midiGtAll);
resultFrameLevel = computeAccuracyFrameLevel(pianoRoll,pianoRollGtAll);
save('result.mat','newH','threshChose','resultFrameLevel','resultNoteLevel','fMeasure');

%% ɾ��������·��
rmpath('..\Libraries\nmflib');
rmpath(genpath('..\code'));
end