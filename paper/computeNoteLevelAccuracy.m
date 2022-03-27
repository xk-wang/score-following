function [results] = computeNoteLevelAccuracy(pianoRoll,pianoRollGT,tol)

% Compute note-level onset-only accuracy (Bay09)


% Expand piano-rolls
expandedPianoRoll = zeros(4*size(pianoRoll,1),88);
for j=1:4*size(pianoRoll,1)
    expandedPianoRoll(j,:) = pianoRoll(floor((j-1)/4)+1,:);
end;

expandedPianoRollGT = zeros(4*size(pianoRollGT,1),88);
for j=1:4*size(pianoRollGT,1)
    expandedPianoRollGT(j,:) = pianoRollGT(floor((j-1)/4)+1,:);
end;

% Find note events on expandedPianoRollGT
auxPianoRoll = diff([zeros(1,88); expandedPianoRollGT; zeros(1,88);],1); k=0;
for i=1:88
    onsets = find(auxPianoRoll(:,i)==1);
    offsets = find(auxPianoRoll(:,i)==-1);
    for j=1:length(onsets)           
        k=k+1;
        nmat2(k,1) = onsets(j)/100;   
        nmat2(k,2) = offsets(j)/100-0.01;   
        nmat2(k,3) = i;     
    end;
end;
nmat2 = sortrows(nmat2,1);


% Number of reference notes
Nref = size(nmat2,1);


% Find note events on expandedPianoRoll
auxPianoRoll = diff([zeros(1,88); expandedPianoRoll; zeros(1,88);],1); k=0;
if (sum(sum(expandedPianoRoll))==0) results.Pre=0; results.Rec=0; results.F=0; results.Acc=0; results.Nref=Nref; return; end; 
for i=1:88
    onsets = find(auxPianoRoll(:,i)==1);
    offsets = find(auxPianoRoll(:,i)==-1);
    for j=1:length(onsets)           
        k=k+1;
        nmat1(k,1) = onsets(j)/100;   
        nmat1(k,2) = offsets(j)/100-0.01;   
        nmat1(k,3) = i;     
    end;
end;
nmat1 = sortrows(nmat1,1);


% Total number of transcribed notes
Ntot = size(nmat1,1);


% Number of correctly transcribed notes, onset within a +/-50 ms range
Ncorr = 0;
for i=1:size(nmat1,1)
    for j=1:size(nmat2,1)
        if( (nmat1(i,3) == nmat2(j,3)) && (abs(nmat2(j,1)-nmat1(i,1))<=tol) )
            Ncorr = Ncorr+1;
        end;
    end;
end;

% Number of false positives, false negatives
Nfp = Ntot-Ncorr;
Nfn = Nref-Ncorr;

% Compute P-R-F
Rec = Ncorr/Nref;
Pre = Ncorr/Ntot;
F = 2*((Pre*Rec)/(Pre+Rec));
Acc= Ncorr/(Ncorr+Nfp+Nfn);

% Create structure for results
results.Rec = Rec;
results.Pre = Pre;
results.F = F;
results.Acc = Acc;
results.Nref = Nref;
