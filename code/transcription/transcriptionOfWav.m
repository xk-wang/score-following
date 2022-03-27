function [h, runTimeOfWav] = transcriptionOfWav(wavPath,fs,frameSize,hopSize,wname,fftSize,template,noteInTemplate,h0,beta,niter)
% transcriptionOfWav 转录wav文件，得到各音符的pitch activation
% 预处理preProcessing；采样数据前后填充半帧0；
% h未指定初始值时随机初始化，指定初始值时，要求初始值行数为频谱模板数，列数至少为音频帧数，第一帧中间时刻为0s，时间分辨率为hopSize/fs
%
% [h, runTimeOfWav] = transcriptionOfWav(wavPath,fs,frameSize,hopSize,wname,fftSize,template,noteInTemplate,h0,beta,niter)
%
% Inputs:
%  wavPath      wav文件的路径
%  fs           采样频率（Hz）
%  frameSize    帧长（samples）
%  hopSize      两连续帧起点的间隔（samples）
%  其它参数见transcriptionOfFrame
%
% Outputs:
%  h            pitch activation，NPITCH x 帧数，第一帧中间时刻为0s，时间分辨率为hopSize/fs
%  runTimeOfWav 转录该音频文件的近似时间、该音频的总帧数

global NPITCH   %多音调检测音符个数
%% 读wav文件
x = preProcessing(wavPath,fs);

%% 对各帧分别进行转录
x = [zeros(round(frameSize/2),1);x;zeros(round(frameSize/2),1)]; %采样数据前后填充半帧0
nFrame = floor((length(x)-frameSize)/hopSize)+1;   %总帧数

if isempty(h0)  %h随机初始化，h0为[]
    h0 = zeros(0,nFrame);
elseif size(h0,2)<nFrame || size(h0,1)~= size(template,2)
    error('h0行数应为频谱模板数，列数至少为音频帧数');
end

h = zeros(NPITCH,nFrame);
curPos = 1;
tic;
for iFrame = 1:nFrame
    xFrame = x(curPos:curPos+frameSize-1);  %当前帧的采样数据
    h(:,iFrame) = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0(:,iFrame),beta,niter);
    curPos = curPos+hopSize;
end
runTimeOfWav = [toc,nFrame];
end