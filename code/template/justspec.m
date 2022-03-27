function spec=justspec(wavPath)
frameSize=4096;
fftSize=4096;
wname=@hamming;
hopSize=441;

x = preProcessing(wavPath);
x = [zeros(round(frameSize/2),1);x;zeros(round(frameSize/2),1)]; %采样数据前后填充半帧0
curPos = 1;
nFrame = floor((length(x)-frameSize)/hopSize)+1;   %总帧数
spec=[];
for iFrame=1:nFrame
    xFrame=x(curPos:curPos+frameSize-1);
    spec(:,iFrame) = spectrumOfFrame(xFrame,wname,fftSize);
    curPos=curPos+hopSize;
end
    

% %% 
% for i=2:2
%     figure(i)
%     
%     
%     %checkpoint=load(['F:\ScoreInformedPianoTranscription\MAPS\ENCl_mistakes\mistake_only\' txt_list(i).name]);
%     %subplot(2,1,1)
%     image((1:length(spec(1,:)))/100,(1:2049)*44100/4096,spec)
%     %     xlim([83 88])
%     ylim([1 2000])
%     hold on
%     
%     octave_num=1;
%     octave_num_mistake=1;
%     minus_20=1;
%     if ~isempty(checkpoint)
%         for j=1:length(checkpoint(:,1))
%             
%             for k=0:octave_num-1
%                 this_octave=checkpoint(j,3)+minus_20*20+12*k;
%                 
%                 if this_octave<96&&this_octave>23
%                     freq_min=note_range(this_octave-23,3);
%                     freq_max=note_range(this_octave-23,4);
%                     duration=checkpoint(j,2)-checkpoint(j,1);
%                     rectangle('Position',[checkpoint(j,1),freq_min+10,duration,(freq_max-freq_min)], 'EdgeColor','c')
%                 end
%                 
%             end
%             hold on
%         end
%         for j=1:length(mistake_this(:,1))
%             for k=octave_num_mistake:-1:0
%                 %             stem(checkpoint(j,1)*100,500);
%                 if k==0
%                     this_octave=mistake_this(j,3)+minus_20*20+12*k;
%                     if this_octave<96&&this_octave>23
%                         freq_min=note_range(this_octave-23,3);
%                         freq_max=note_range(this_octave-23,4);
%                         duration=mistake_this(j,2)-mistake_this(j,1);
%                         rectangle('Position',[mistake_this(j,1),freq_min+10,duration,(freq_max-freq_min)], 'EdgeColor','r')
%                     end
%                 else
%                     this_octave=mistake_this(j,3)+12*k;
%                     if this_octave<96&&this_octave>23
%                         freq_min=note_range(this_octave-23,3);
%                         freq_max=note_range(this_octave-23,4);
%                         duration=mistake_this(j,2)-mistake_this(j,1);
%                         rectangle('Position',[mistake_this(j,1),freq_min+10,duration,(freq_max-freq_min)], 'EdgeColor','r')
%                     end
%                     
%                     
%                     
%                 end
%             end
%             
%             
%         end
%         hold off
%     end
% end
