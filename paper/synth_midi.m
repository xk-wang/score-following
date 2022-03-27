function [dat,sr] = synth_midi(filename, varargin)
% function [dat,sr] = synth_midi(filename, varargin)
%
% Uses timidity to synthesize a MIDI file and return the audio. 
%
% Input:
%   filename [str]  - Complete filename of the MIDI file to render
%  OPTIONAL (passed in name-value pairs):
%   dsr      [num]  - Desired sampling rate [8000]
%   mono     [bool] - Render mono? [1]
%   tempo    [num]  - Tempo (in BPM) to render MIDI file at.  If empty, the 
%                     file will be rendered as-is [[]]
%   cfg      [str]  - Timidity config file to use ['']
%   trim_end [num]  - If greater than 0, the rendered output will be
%                     'trimmed' so that excess silence is removed. The
%                     actual value of trim_end is used as a threshold.  If 0, 
%                     output is trimmed to match duration implied by MIDI
%                     file (with tempo), and if negative, no trimming done. [0]
%   insts    [vec] -  General MIDI numbers to use for each channel.  
%                     If empty, leave things alone. [[]]
%
% Output:
%   dat      [mat]  - Audio samples (nsamples x nchannels)
%   sr       [num]  - Sampling rate of audio samples.  Just returned for
%                     convenience.
%

% Copyright (C) 2010-2030 Graham Grindlay (grindlay@ee.columbia.edu)
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% process arguments
[dsr, mono, new_tempo, cfg, trim_end, insts] = ...
    parse_opt(varargin, 'dsr', 8000, ...
                        'mono', 1, ...
                        'tempo', 60, ...
                        'cfg', '', ...
                        'trim_end', 0, ...
                        'insts', []);

% if we got instruments, just load the MIDI file and then call synth_nmat
if ~isempty(insts)
    nmat = readmidi_java(filename);
    [dat,sr] = synth_nmat(nmat, 'dsr', dsr, 'mono', mono, ...
                                'tempo', new_tempo, 'cfg', cfg, ...
                                'trim_end', trim_end, 'insts', insts);
    % we're done so exit
    return;
end

cmd = 'D:\Timidity\timidity\timidity ';

if ~isempty(cfg)
    cmd = [cmd '-c ' cfg];
end

cmd = [cmd ' '];

if mono
    cmd = [cmd '--output-mono '];
end

tmpwav = 'temp.wav';
%tmpwav = [tempname() '.wav'];

% read the MIDI file into an nmat so that we can do tempo adjustments
% and/or get total duration
nmat = readmidi_java(filename);

%%%
% Anssi's hack for inserting dummy event for same duration
nmat = [0 9 1 1 1 0 0; nmat];
writemidi_java(nmat,'temp.mid',120,120,4,4);
%nmat2midi(nmat,'temp.mid',100);
filename = 'temp.mid';
%%%


if ~isempty(new_tempo)
    curr_tempo = gettempo(nmat);
    tempo_percent = 100*(new_tempo/curr_tempo);
    
    % make new nmat in case we need to trim
    nmat = settempo(nmat, new_tempo);
    
    %cmd = [cmd '-s ' num2str(dsr) ' -T ' num2str(tempo_percent) ' ' ...
    cmd = [cmd '-c' ' D:\Timidity\timidity\TimGM6mb.cfg' ' -s ' num2str(44100) ' -T ' num2str(tempo_percent) ' ' ...
           filename ' -Ow -o ' tmpwav];
else % just synthesize the file as-is
    cmd = [cmd '-c' ' D:\Timidity\timidity\TimGM6mb.cfg' ' -s ' num2str(44100) ' ' filename ' -Ow -o ' tmpwav];
end

% now call timidity to synthesize the file to a temporary file
[status,res] = system(cmd);
[dat,sr] = wavread(tmpwav);

% finally, do trimming if asked
if trim_end > 0
    dat = trim_by_env(dat, trim_end);
elseif trim_end == 0
    dat = dat(1:nmat_dur(nmat)*sr); %!!!!!!!! 
end
