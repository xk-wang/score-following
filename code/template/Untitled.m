
wavPath='H:\0814\MAPS_MUS-alb_se3_AkPnBcht.wav';
%wavPath='H:\测试数据集\1_2017-06-15 09_39_07 +0000印第安小勇士\1_2017-06-15 09_39_07 +0000印第安小勇士.wav';
resamplefs=11025;
frameSize=1024;
hopSize=512;
wname=@hamming;
fftSize=1024;
template=temp11025;
h0=ones(89,1000000);
Beta=0.6;
niter=15;
x=audioread(wavPath);
if size(x,2)>1
    x = mean(x,2);
end
adjust=1;
xFrame=x(350000:350000+1023);
noteInTemplate=[1:88];
h0Frame=ones(88,1);
[h, runTimeOfWav,allframe,allspec,allerrs,allframe1024,t_all] =  transcriptionOfWav(wavPath,resamplefs,frameSize,hopSize,wname,fftSize,template,[],h0,Beta,niter);
%[newH,spectrum,errs,t] = transcriptionOfFrame(xFrame,wname,fftSize,template,noteInTemplate,h0Frame,Beta,niter,resamplefs);