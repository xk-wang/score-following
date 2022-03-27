function spectrum = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize)
% spectrumOfSignal ���źŽ���STFT�����������
% ��������ǰ������֡0�����һ֡�м�ʱ��Ϊ0s
%
% spectrum = spectrumOfSignal(x,frameSize,hopSize,wname,fftSize)
%
% Inputs:
%  x            �������źţ���������
%  frameSize    ֡����samples��
%  hopSize      ������֡���ļ����samples��
%  wname        ���������ƣ���@hamming��@hann��
%  fftSize      FFT���ȣ�samples��
%
% Outputs:
%  spectrum     ����ף�ǰ��Σ�(floor(fftSize/2)+1) x ֡����

if size(x,2)~=1
    error('�����ź�xӦΪ������');
end

x = [zeros(round(frameSize/2),1);x;zeros(round(frameSize/2),1)];  %��������ǰ������֡0
nFrame = floor((length(x)-frameSize)/hopSize)+1;    %��֡��
spectrum = zeros(floor(fftSize/2)+1,nFrame);
curPos = 1;
for iFrame = 1:nFrame
    xFrame = x(curPos:curPos+frameSize-1);  %��ǰ֡�Ĳ�������
    spectrum(:,iFrame) = spectrumOfFrame(xFrame,wname,fftSize);
    curPos = curPos+hopSize;
end
end