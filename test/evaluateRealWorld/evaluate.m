function evaluate(datasetPath,frameSize,hopSize,wname,fftSize,beta,niter)
% evaluate('..\Dataset\realWorldTest\MUS\PC', 4096, 441, @hamming, 4096, 0.6, 15)

%% 添加依赖库路径
addpath('..\Libraries\nmflib');
addpath(genpath('..\code'));

%% 分别对各.wav文件计算STFT

%% 载入ground truth

%% 用NMF with beta-divergence算法进行多音调检测
load('spectrumAll.mat');
load('templatePC.mat');
nTemplate = size(template,2);  %频谱模板总数
nFrameAll = size(spectrumAll,2);
h = zeros(nTemplate,nFrameAll);

%% 随机初始化

%% ground truth初始化
% 随机初始化得到的H中应判为1/0的activition的均值分别为115.5188、0.5984
load('H0Gt264.mat');

% 根据模板调整H0
noteIndex = noteList;   %模板中音符对应于H0的行数
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

%% post processing及评价
fs = 44100;
newH = formatHTo88Rows(h,noteList{1});  %要求各套模板音符相同
load('gtAll.mat');
[threshChose,fMeasure] = chooseThresh(newH,pianoRollGtAll,midiGtAll);
pianoRoll = double(newH>threshChose);
midi = convertPianoRollToMidi(pianoRoll,hopSize/fs);
resultNoteLevel = computeAccuracyNoteLevel(midi,midiGtAll);
resultFrameLevel = computeAccuracyFrameLevel(pianoRoll,pianoRollGtAll);
save('result.mat','newH','threshChose','resultFrameLevel','resultNoteLevel','fMeasure');

%% 删除依赖库路径
rmpath('..\Libraries\nmflib');
rmpath(genpath('..\code'));
end