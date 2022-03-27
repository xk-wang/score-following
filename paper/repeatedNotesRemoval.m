function [newExpandedPath] = repeatedNotesRemoval(expandedPath,E)


% Initialize
warning off
noteIndex = (1:10:871);

auxPianoRoll = diff([zeros(1,88); expandedPath; zeros(1,88);],1);
expandedE = E;


% For each pitch
for i=2:88
    
    onsets = find(auxPianoRoll(:,i)==1);
    offsets = find(auxPianoRoll(:,i)==-1);
    
    pitcharea1 = expandedE(:,noteIndex(i)-4:noteIndex(i)+4);
    pitcharea2 = expandedE(:,noteIndex(i)-4+120:noteIndex(i)+4+120);
    pitcharea = [pitcharea1 pitcharea2];
    
    SF = max(diff(sum(medfilt1(pitcharea,5)')),0);
    newSF = max(SF-medfilt1(SF,20),0);
    %figure; plot(newSF);
    [pks,locs] = findpeaks(newSF,'minpeakdistance',15,'minpeakheight',0.4);
    
    
    for j=1:length(onsets)            % For each event in the pitch
        
        for k=1:length(locs)
        
            if(~isempty(find(onsets(j)+5:offsets(j) == locs(k),1))) expandedPath(locs(k)-1,i)=0; end;
        
        end;
        
    end;
    
    
end;

newExpandedPath = expandedPath;
