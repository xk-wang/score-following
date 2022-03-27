wavPath1='F:\ScoreInformedPianoTranscription\MAPS\midi\AkPnCGdD\MUS\MAPS_MUS-liz_rhap02_AkPnCGdD.wav';
mode=0;
spec1=justspec(wavPath1);
hop=441;
figure(1)
imagesc(spec1)

wavPath2='F:\ScoreInformedPianoTranscription\MAPS\midi\ENSTDkAm\MUS\MAPS_MUS-liz_rhap02_ENSTDkAm.wav';
mode=0;
spec2=justspec(wavPath2);
hop=441;
figure(2)
imagesc(spec2)

% hold on

% for i=1:length(ljmark2)
%      plot([ljmark2(i)*44100/512,ljmark2(i)*44100/512],[1,4096],'g--'); hold on;
% end
% if mode==1
%     for i=1:length(gxmark)
%         plot([gxmark(i,1)*44100/hop,gxmark(i,1)*44100/hop],[1,4096],'w'); hold on;
%     end
%     
% end
% 
% for i=1:length(ljmark)
%      plot([ljmark(i)*44100/hop,ljmark(i)*44100/hop],[1,4096],'g--'); hold on;
% end