function [h, runTimeOfWav] = transcriptionOfWav(wavPath,fs,frameSize,hopSize,wname,fftSize,template,noteInTemplate,h0,beta,niter)
% transcriptionOfWav ת¼wav�ļ����õ���������pitch activation
% Ԥ����preProcessing����������ǰ������֡0��
% hδָ����ʼֵʱ�����ʼ����ָ����ʼֵʱ��Ҫ���ʼֵ����ΪƵ��ģ��������������Ϊ��Ƶ֡������һ֡�м�ʱ��Ϊ0s��ʱ��ֱ���ΪhopSize/fs
%
% [h, runTimeOfWav] = transcriptionOfWav(wavPath,fs,frameSize,hopSize,wname,fftSize,template,noteInTemplate,h0,beta,niter)
%
% Inputs:
%  wavPath      wav�ļ���·��
%  fs           ����Ƶ�ʣ�Hz��
%  frameSize    ֡����samples��
%  hopSize      ������֡���ļ����samples��
%  ����������transcriptionOfFrame
%
% Outputs:
%  h            pitch activation��NPITCH x ֡������һ֡�м�ʱ��Ϊ0s��ʱ��ֱ���ΪhopSize/fs
%  runTimeOfWav ת¼����Ƶ�ļ��Ľ���ʱ�䡢����Ƶ����֡��

global NPITCH   %�����������������
%% ��wav�ļ�
x = preProcessing(wavPath,fs);

%% �Ը�֡�ֱ����ת¼
x = [zeros(round(frameSize/2),1);x;zeros(round(frameSize/2),1)]; %��������ǰ������֡0
nFrame = floor((length(x)-frameSize)/hopSize)+1;   %��֡��

if isempty(h0)  %h�����ʼ����h0Ϊ[]
    h0 = zeros(0,nFrame);
elseif size(h0,2)<nFrame || size(h0,1)~= size(template,2)
    error('h0����ӦΪƵ��ģ��������������Ϊ��Ƶ֡��');
end

h = zeros(NPITCH,nFrame);
curPos = 1;
tic;
for iFrame = 1:nFrame
    xFrame = x(curPos:curPos+frameSize-1);  %��ǰ֡�Ĳ�������
    h(:,iFrame) = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0(:,iFrame),beta,niter);
    curPos = curPos+hopSize;
end
runTimeOfWav = [toc,nFrame];
end