function [newSmoothPianoRoll] = repeatedNotesRemoval2(salience,smoothPianoRoll)


% Initialize
warning off
auxSalience = diff([zeros(1,88); salience; zeros(1,88);],1);
auxSalience = max(auxSalience,0);
auxPianoRoll = diff([zeros(1,88); smoothPianoRoll; zeros(1,88);],1);
%figure; imagesc(auxSalience'); axis xy


% For each pitch
for i=1:88
    
    onsets = find(auxPianoRoll(:,i)==1);
    offsets = find(auxPianoRoll(:,i)==-1);
    
    [pks,locs] = findpeaks(auxSalience(:,i),'minpeakdistance',3,'minpeakheight',1.4);
        
    
    % For each event in the pitch
    for j=1:length(onsets)                
        
        for k=1:length(locs)
        
            if(~isempty(find(onsets(j)+5:offsets(j) == locs(k),1))) smoothPianoRoll(locs(k)-1,i)=0; end;
        
        end;
        
    end;
    
end;

newSmoothPianoRoll = smoothPianoRoll';
