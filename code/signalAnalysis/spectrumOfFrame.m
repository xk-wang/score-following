function spectrum = spectrumOfFrame(xFrame,wname,fftSize)
% spectrumOfFrame ��һ֡�źŽ���FFT�����������
% ��֡-�Ӵ�-ĩβ����-FFT������=֡����Ϊż��ʱ����������DFTż�Գ�
%
% spectrum = spectrumOfFrame(xFrame,wname,fftSize)
%
% Inputs:
%  xFrame   һ֡��Ƶ������������������Ϊ֡����
%  wname    ���������ƣ���@hamming��@hann��
%  fftSize  FFT���ȣ�samples��
%
% Outputs:
%  spectrum ����ף�ǰ��Σ�(floor(fftSize/2)+1) x 1��

if size(xFrame,2)~=1
    error('������Ƶ����xFrameӦΪ������');
end

win = window(wname,length(xFrame),'periodic');
xFrame = xFrame.*win;
fftFrame = fft(xFrame,fftSize);
spectrum = abs(fftFrame(1:fftSize/2+1));
end