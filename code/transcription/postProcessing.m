function [pianoRoll,midi] = postProcessing(h,varargin)
% postProcessing ����pitch activation�õ�ת¼������ֱ��ʾΪpiano roll��ʽ��midi��ʽ
% ������ֵ�˲���note tracking�����Ա�Ƶ�������ʱ��Լ��
%
% [pianoRoll,midi] = postProcessing(h,varargin)
%
% Inputs����h�⣬������Ϊ��ѡ�������Ա�����-ֵ�Է�ʽ���룩��
%  h                        ����ʽ�ֽ��㷨�����pitch activation��һ�ж�Ӧһ����������i�ж�Ӧ��ʱ��Ϊ(i-1)*timeResolution
%  medfiltFlag              �Ƿ��pitch activation������ֵ�˲���1�����У������������� [0]
%  nSample                  ��ֵ�˲����� [7]
%  noteTrackingFlag         note tracking������0������ֵ��������HMM [0]
%  threshold                pitch activation����ֵ��>�� [0]
%  coeff                    thresholdΪ��ʱ����֡��ֵΪH���ֵ*coeff
%  minTh                    thresholdΪ��ʱ����ֵ����Сֵ
%  lambda                   CRF���� [0.1]
%  noteTransitions          CRF������3ά����һά��Ӧ������������h���ж�Ӧ������һ��
%  nMaxFlag                 �Ƿ��������polyphonic levelȡH����ǰnMax��
%  nMax
%  ignoreOctaveErrorsFlag   �Ƿ���Ա�Ƶ����1�����ԣ������������� [0]
%  pianoRollGt              ground truth�����Ա�Ƶ����ʱ��Ҫ�����룩 [[]]��
%                           Ҫ��h��pianoRollGt���ж�Ӧ��������ͬ���к����12���ж�Ӧ������Ϊ�˶ȹ�ϵ�����ж�Ӧ��ʱ����ͬ
%  minDurFlag               ���ʱ��Լ���ķ�ʽ��1����ʵʱ��2��ʵʱ�����������������ʱ��Լ�� [0]
%  timeResolution           h���������е�ʱ��s�� [0.01]
%  minDur                   ���������ʱ��Լ����s����>=�� [0.06]
%
% Outputs:
%  pianoRoll    �������������piano roll��ʽ��88��
%  midi         note tracking�����midi��ʽ
%
% ���Ա�Ƶ���󣬼��ֵ��ο�ֵƥ��ʱ�����Զࣨ������һ��һ����������ƥ�䣩
% ���ʱ��Լ��ʵʱ��ʽ����⵽��������������minDur�󣬲���Ϊ������������
% δ��ɣ��Կ��ܱ�����������ӵ���ֵ���Կ���û������������Ӹ���ֵ
% ����֤�����ʱ��Լ�������ַ�ʽ�õ���MIDI�Ƿ���ͬ

%% �����������
[medfiltFlag, nSample,noteTrackingFlag, threshold, coeff,minTh, lambda,noteTransitions,nMaxFlag,nMax,ignoreOctaveErrorsFlag, pianoRollGt, minDurFlag, timeResolution, minDur] = ...
    parse_opt(varargin, 'medfiltFlag', 0, 'nSample', 7,...
    'noteTrackingFlag', 0, 'threshold', 0, 'coeff', 0.25, 'minTh', 250, ...
    'lambda',0.1,'noteTransitions',[],...
    'nMaxFlag',1,'nMax',2,...
    'ignoreOctaveErrorsFlag', 0, 'pianoRollGt', [], ...
    'minDurFlag', 0, 'timeResolution', 0.01, 'minDur', 0.06);

%% ��ֵ�˲�
if medfiltFlag == 1
    h = medfilt1(h',nSample)';  %Ҫ��h �ж�Ӧ����
end

%% ����ֵ
if noteTrackingFlag == 0
    if isempty(threshold)
        pianoRoll = zeros(size(h));
        for iFrame = 1:size(h,2)
            thisTh = max(max(h(:,iFrame))*coeff,minTh);
            pianoRoll(:,iFrame) = double(h(:,iFrame)>thisTh);
        end
    elseif length(threshold)==1
        pianoRoll = double(h>threshold);
    else
        pianoRoll = zeros(size(h));
        for iPitch = 1:size(h,1)
            pianoRoll(iPitch,:) = double(h(iPitch,:)>threshold(iPitch));
        end
    end
else
    [nPitch,nFrame] = size(h);
    pianoRoll = zeros(nPitch,nFrame);
    nodePot = zeros(nFrame,2);
    for iPitch = 1:nPitch
        bbb = 0.5*(h(iPitch,:)+[0 h(iPitch,1:nFrame-1)])*lambda;
        nodePot(:,1) = exp(-bbb);
        nodePot(:,2) = 1-exp(-bbb);
        pianoRoll(iPitch,:) = crfChain_decode(nodePot,squeeze(noteTransitions(iPitch,:,:)));
    end
    pianoRoll = pianoRoll-1;
end

%% ��������polyphonic levelȡH����ǰnMax��
if nMaxFlag
    for iFrame =1:size(pianoRoll,2)
        if sum(pianoRoll(:,iFrame))>nMax
            [~,index] = sort(h(:,iFrame));
            pianoRoll(index(nMax+1:end),iFrame) = 0;
        end
    end
end

%% ���Ա�Ƶ����
if ignoreOctaveErrorsFlag == 1  %Ҫ��pianoRoll��pianoRollGt���ж�Ӧ��ʱ����ͬ
    nCol = min(size(pianoRoll,2),size(pianoRollGt,2));
    for iFrame = 1:nCol
        pianoRoll(:,iFrame) = ignoreOctaveErrors(pianoRoll(:,iFrame),pianoRollGt(:,iFrame));    %Ҫ�󣺼�ignoreOctaveErrors
    end
end

%% ���ʱ��Լ��
if minDurFlag == 1  %��ʵʱ
    [midi,pianoRoll] = pianoRollToMidi(pianoRoll,timeResolution,minDur);
elseif minDurFlag == 2    %ʵʱ����⵽��������������minDur�󣬲���Ϊ������������
    noteDurCount = zeros(size(pianoRoll,1),1);  %�����������������֡��
    for iFrame = 1:size(pianoRoll,2)
        [pianoRoll(:,iFrame),noteDurCount] = minDurConstraint(pianoRoll(:,iFrame),noteDurCount,timeResolution,minDur);
    end
    
    [midi,~] = pianoRollToMidi(pianoRoll,timeResolution);
    midi(:,2) = midi(:,2)-ceil(minDur/timeResolution)*timeResolution;
else
    [midi,~] = pianoRollToMidi(pianoRoll,timeResolution);
end
end

function pianoRollChanged = ignoreOctaveErrors(pianoRollFrame,pianoRollGtFrame)
% ignoreOctaveErrors ���Ա�Ƶ����ʱ���޸�ԭʼ�����������
% ���ֵ��ο�ֵƥ��ʱ�����Զࣨ������һ��һ����������ƥ�䣩
%
% Inputs:
%  pianoRollFrame   1֡ԭʼ�������������������
%  pianoRollGtFrame ��Ӧ��ground truth��piano roll��ʽ
%  Ҫ��pianoRollFrame��pianoRollGtFrame���ж�Ӧ��������ͬ���к����12���ж�Ӧ������Ϊ�˶ȹ�ϵ
%
% Outputs:
%  pianoRollChanged ���Ա�Ƶ����ʱ�Ķ����������

pianoRollChanged = zeros(size(pianoRollFrame));
noteTot = find(pianoRollFrame==1);
noteRef = find(pianoRollGtFrame==1);
isMatched = zeros(length(noteTot),1);  %����ָʾת¼�õ���������ground truth���Ƿ���ƥ��
for iNoteRef = 1:length(noteRef)
    indexRef = noteRef(iNoteRef);       %ground truth���������к�
    for iNoteTot = 1:length(noteTot)
        indexTot = noteTot(iNoteTot);   %ת¼�õ����������к�
        if mod(indexRef-indexTot,12) == 0
            pianoRollChanged(indexRef) = 1;  %ת¼��ȷ������
            isMatched(iNoteTot) = 1;
        end
    end
end
pianoRollChanged(noteTot(isMatched==0)) = 1; %false positives
end

function [pianoRollFrame,noteDurCount] = minDurConstraint(pianoRollFrame,noteDurCount,timeResolution,minDur)
% minDurConstraint �Զ�����������������ʱ��Լ��������⵽��������������minDur�󣬲���Ϊ������������
%
% Inputs:
%  pianoRollFrame   1��
%  noteDurCount     �����������������֡��
%  timeResolution   pianoRoll���������е�ʱ��s��
%  minDur           ���������ʱ��Լ����s����>=��
%  Ҫ��pianoRollFrame��noteDurCountά����ͬ
%
% Outputs:
%  pianoRollFrame   ������ʱ��Լ����Ķ����������

minNFrame = ceil(minDur/timeResolution)+1;   %���ʱ����Ӧ��֡��
for iNote = 1:length(pianoRollFrame)
    if pianoRollFrame(iNote)==0
        noteDurCount(iNote) = 0;
    else
        noteDurCount(iNote) = noteDurCount(iNote)+1;
        if noteDurCount(iNote)<minNFrame
            pianoRollFrame(iNote) = 0;
        end
    end
end
end