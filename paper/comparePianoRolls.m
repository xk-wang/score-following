function [pianoRollResult] = comparePianoRolls(onsetTol,pianoRollTrans,pianoRollSynthGT,pianoRollGT,pianoRollStrict,pianoRollRelaxed)

% Initialize
pianoRollResult = zeros(size(pianoRollGT,1),88);
auxPianoRollGT = diff([zeros(1,88); pianoRollGT; zeros(1,88);],1);
auxPianoRollTrans = diff([zeros(1,88); pianoRollTrans; zeros(1,88);],1);
auxPianoRollSynthGT = diff([zeros(1,88); pianoRollSynthGT; zeros(1,88);],1);
tol = onsetTol;  % Onset tolerance in samples


% For each onset in GT
for i=1:88
    
    onsetsGT = find(auxPianoRollGT(:,i)==1);
    onsetsTrans = find(auxPianoRollTrans(:,i)==1);
    onsetsSynthGT = find(auxPianoRollSynthGT(:,i)==1);
    offsetsGT = find(auxPianoRollGT(:,i)==-1);
    offsetsTrans = find(auxPianoRollTrans(:,i)==-1);

    
    for j=1:length(onsetsGT)
        if (~isempty(find(onsetsTrans > onsetsGT(j)-tol & onsetsTrans < onsetsGT(j)+tol,1)))
            pianoRollResult(onsetsGT(j):offsetsGT(j)-1,i) = 1;       % Correct note
        else
           if (~isempty(find(onsetsSynthGT > onsetsGT(j)-tol/2 & onsetsSynthGT < onsetsGT(j)+tol/2,1))) %% tol/2!!
               pianoRollResult(onsetsGT(j):offsetsGT(j)-1,i) = 0.5;  % Miss detection
           else
               pianoRollResult(onsetsGT(j):offsetsGT(j)-1,i) = 0.8; %Unknown (set as correct)
           end;
        end;
    end;
    
    
    for j=1:length(onsetsTrans)
        if (isempty(find(onsetsGT > onsetsTrans(j)-tol & onsetsGT < onsetsTrans(j)+tol,1)))
           if (isempty(find(onsetsSynthGT > onsetsTrans(j)-tol & onsetsSynthGT < onsetsTrans(j)+tol,1)))
               pianoRollResult(onsetsTrans(j):offsetsTrans(j)-1,i) = 0.2; % False Alarm
           end;
        end;
    end;    
    
end;

%figure; imagesc(imrotate(pianoRollResult,90));


% Re-process detected false alarms
falseAlarmPianoRoll = double(pianoRollResult == 0.2);
auxPianoRollFalseAlarm = diff([zeros(1,88); falseAlarmPianoRoll; zeros(1,88);],1);
auxPianoRollStrict = diff([zeros(1,88); pianoRollStrict; zeros(1,88);],1);

for i=1:88
    onsetsFalse = find(auxPianoRollFalseAlarm(:,i)==1);
    onsetsStrict = find(auxPianoRollStrict(:,i)==1);
    offsetsFalse = find(auxPianoRollFalseAlarm(:,i)==-1);
    
    for j=1:length(onsetsFalse)
        if (isempty(find(onsetsStrict > onsetsFalse(j)-tol & onsetsStrict < onsetsFalse(j)+tol,1)))
            pianoRollResult(onsetsFalse(j):offsetsFalse(j)-1,i) = 0;  % Remove falseley detected FAs
        end
    end;
end;


% Re-process detected miss detections
missDetectionPianoRoll = double(pianoRollResult == 0.5);
auxPianoRollMissDetection = diff([zeros(1,88); missDetectionPianoRoll; zeros(1,88);],1);
auxPianoRollRelaxed = diff([zeros(1,88); pianoRollRelaxed; zeros(1,88);],1);

for i=1:88
    onsetsMiss = find(auxPianoRollMissDetection(:,i)==1);
    onsetsRelaxed = find(auxPianoRollRelaxed(:,i)==1);
    offsetsMiss = find(auxPianoRollMissDetection(:,i)==-1);
    
    for j=1:length(onsetsMiss)
        if (~isempty(find(onsetsRelaxed > onsetsMiss(j)-tol & onsetsRelaxed < onsetsMiss(j)+tol,1)))
            pianoRollResult(onsetsMiss(j):offsetsMiss(j)-1,i) = 1;  % Correct falsely detected MDs
        end
    end;
end;

