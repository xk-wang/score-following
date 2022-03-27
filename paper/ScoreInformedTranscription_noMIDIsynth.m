function [results wAcc wF] = ScoreInformedTranscription_noMIDIsynth(filename,numIter,smoothSynth, smoothNormal, smoothStrict, smothRelaxed, onsetTol)
% e.g. ScoreInformedTranscription('Disklavier_01_G1_A2.wav', 15, 2.0, 1.3, 0.7, 2.7, 5);


% ==== INITIALIZE ==== %

% Load Disklavier note templates
load noteTemplatesDisklavier1
load noteTemplatesDisklavier2
load noteTemplatesDisklavier3
load noteTemplatesDisklavier4
DisklavierNoteTemplates = [noteTemplatesDisklavier1; noteTemplatesDisklavier2; noteTemplatesDisklavier3; noteTemplatesDisklavier4];
clear('noteTemplatesDisklavier1','noteTemplatesDisklavier2','noteTemplatesDisklavier3','noteTemplatesDisklavier4');

% load ground truth
filename = strrep(filename, '.wav', '');
[pianoRoll_correct,nmat] = convertMIDIToPianoRoll(['Dataset/' filename '_correct' '.mid'],40,1);
[pianoRoll_fa,nmat] = convertMIDIToPianoRoll(['Dataset/' filename '_fa' '.mid'],40,1);
[pianoRoll_missed,nmat] = convertMIDIToPianoRoll(['Dataset/' filename '_missed' '.mid'],40,1);
[pianoRoll_gt,nmat] = convertMIDIToPianoRoll(['Dataset/' filename '_gt' '.mid'],40,1);
%[pianoRoll_gt,nmat] = convertMIDIToPianoRoll(['Dataset/' filename '_Rob' '.mid'],40,1);
if (size(pianoRoll_correct,1) > size(pianoRoll_fa,1))
pianoRoll_student_gt = pianoRoll_correct + [pianoRoll_fa; zeros(size(pianoRoll_correct,1) - size(pianoRoll_fa,1),88)];
elseif (size(pianoRoll_correct,1) < size(pianoRoll_fa,1))
pianoRoll_student_gt = pianoRoll_fa + [pianoRoll_correct; zeros(size(pianoRoll_fa,1) - size(pianoRoll_correct,1),88)];
end;

%figure; imagesc(pianoRoll_gt'); axis xy


% ==== COMPUTE CQTs ==== %

% Load recording and compute CQT (40ms step)
[intCQT] = computeCQT(['Dataset/' filename '.wav']);
X = intCQT(:,round(1:4*8.1670:size(intCQT,2)))';
noiseLevel1 = medfilt1(X',40);
noiseLevel2 = medfilt1(min(X',noiseLevel1),40);
X = max(X-noiseLevel2',0);
clear('intCQT','noiseLevel1','noiseLevel2');
%figure; imagesc(X'); axis xy


% % ==== MAIN ALGORITHM ==== %

% Perofrm NMF with beta-divergence to recording
[W,H,errs,vout] = nmf_beta(X',352,'W0',DisklavierNoteTemplates','W',DisklavierNoteTemplates','niter', numIter, 'verb', 3,'beta',0.6);
newH = H(1:88,:) + H(88+1:88+88,:) + H(88+88+1:88+88+88,:) + H(88+88+88+1:88+88+88+88,:);
newH = medfilt1(newH',3)';
%figure; imagesc(newH); axis xy


% Post-processing using CRFs
pianoRoll = double(newH>0.01);
[B,smoothPianoRoll] = postProcessingCRF(pianoRoll',newH',smoothNormal);
smoothPianoRoll = repeatedNotesRemoval2(newH',smoothPianoRoll');
%figure; imagesc(smoothPianoRoll); axis xy



% % ==== COMPARE THE THREE PIANO-ROLLS ==== %
[B,smoothPianoRollStrict] = postProcessingCRF(pianoRoll',newH',smoothStrict); % Produce piano roll with more smoothing (for discarding FAs)
smoothPianoRollStrict = repeatedNotesRemoval2(newH',smoothPianoRollStrict');
[B,smoothPianoRollRelaxed] = postProcessingCRF(pianoRoll',newH',smothRelaxed); % Produce piano roll with less smoothing (for discarding MDs)
smoothPianoRollRelaxed = repeatedNotesRemoval2(newH',smoothPianoRollRelaxed');
%figure; imagesc(smoothPianoRollStrict); axis xy
%figure; imagesc(smoothPianoRollRelaxed); axis xy


[pianoRollResult] = comparePianoRolls_Rob_noMIDIsynth(onsetTol,smoothPianoRoll',pianoRoll_gt,smoothPianoRollStrict',smoothPianoRollRelaxed');
%figure; imagesc(pianoRollResult'); axis xy



% ==== EVALUATION ==== %

% Compare recording transcription with student ground-truth
resultsRecording = computeNoteLevelAccuracy(smoothPianoRoll',pianoRoll_student_gt,0.1);

% Compare synthesised transcription with aligned score ground-truth
resultsSynthesised = computeNoteLevelAccuracy(smoothPianoRoll',pianoRoll_student_gt,0.1);  % useless

% Evaluate pianoRollResult
resultsCorrect = computeNoteLevelAccuracy(pianoRollResult==1,pianoRoll_correct,0.1);
resultsMissed = computeNoteLevelAccuracy(pianoRollResult==0.5,pianoRoll_missed,0.1);
resultsFA = computeNoteLevelAccuracy(pianoRollResult==0.2,pianoRoll_fa,0.1);

results = [resultsRecording resultsSynthesised resultsCorrect resultsMissed resultsFA];

% Weighted Accuracy
wAcc = (results(3).Acc * results(3).Nref + results(4).Acc * results(4).Nref + results(5).Acc * results(5).Nref) / (results(3).Nref+results(4).Nref+results(5).Nref);

% Weighted F
wF = (results(3).F * results(3).Nref + results(4).F * results(4).Nref + results(5).F * results(5).Nref) / (results(3).Nref+results(4).Nref+results(5).Nref);
