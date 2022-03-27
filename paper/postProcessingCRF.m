function [B,path] = postProcessingCRF(expandedPianoRoll,expandedSalience,aaa)


% Initialize
load stateDynamics;
expandedSalience2 = [zeros(1,88); expandedSalience(1:end-1,:)];
path = zeros(88,size(expandedPianoRoll,1));
B = zeros(88,size(expandedPianoRoll,1),2);


% For each pitch, compute observation likelihood
for i=1:88
    
    bbb = 0.5*(expandedSalience(:,i)+expandedSalience2(:,i))*aaa;
    
    B(i,:,1) = 1 - (1 - exp(-bbb));
    
    B(i,:,2) = 1 - exp(-bbb);
    
    path(i,:) = crfChain_decode(squeeze(B(i,:,:)),squeeze(noteTransitions(i,:,:)));
    
end;

path = path-1;
