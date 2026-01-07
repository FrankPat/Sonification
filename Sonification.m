function [ScaleIndices,NewFreq] = Sonification(yData,LowestSeq,Key, ...
    SeqLength,FileName,IPmethod,scale,flag)

% Function that transforms any dataseries (preferably a multiple of 8 or 16
% data points) into a musical sequence.
%
% INPUT
% yData       =  one-dimensional vector containing numerical data
% StartingSeq =  lowest note in the chosen scale (1-7), where 1 = C in the scale of C
% Key         =  major key of the sequence (C, Db, D, Eb, ...)
% SeqLength   =  tonal span of the sequence (14 = 2 octaves)
% FileName    =  name of outputfile (without extension)
% IPmethod    =  mapping method: 1: frequency; 2: logarithmic frequency
%                  (linear scale); 3: equidistant
% scale       =  type of scale: Major, Pentatonic, Blues (major)
% flag        =  0: only abc output file is created
%                1: abc software and ps2pdf is executed to produce a pdf
%                   file with sheet music
%
% OUTPUT
% Filename.abc: Text file written with musical written in abc notation
% (https://abcnotation.com/). The file has the extension '.abc'
% If 'flag=1', the abc2ps programme will be executed and a pdf file created
% with the sheet music. This requires installation of the abc notation
% software as well as ghostscript and ps2pdf.
% Alternatively the .abc file can be transformed into sheet music using
% online abc tools (see https://abcnotation.com/ for more info).
%
% Filename.mid: MIDI file with output of the track that can be imported in
% a DAW (using subroutines listed below).
%
% Filename.mat: Matrix M with basic MIDI information for further editing.
% Can be translated into a MIDI file with the commands
% midi=matrix2midi(M) and writemidi(midi, midifile), taken from 
% https://kenschutte.com/midi/ and https://github.com/kts/matlab-midi/
%
%
% MIT License
%
% Copyright (c) 2025 Frank Pattyn
% 
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    Sequence=length(yData);
    Lines=Sequence/16;
    if Lines<1
        Lines=1;
        maxj=2;
    else
        maxj=4;
    end
    ScaleNames={'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'};
    f0=440; % A4 as standard frequency
    if cellfun(@strcmp,scale,{'Major'})
        C4s=[-9 -7 -5 -4 -2 0 2]; % Standard C4 to C5 scale, with A4 = 0
    elseif cellfun(@strcmp,scale,{'Pentatonic'}) % pentatonic scale
        C4s=[-9 -7 -5 -2 0];
    elseif cellfun(@strcmp,scale,{'Blues'}) % minor blues scale
        C4s=[-9 -7 -6 -5 -2 0];
    else
        fprintf('scale options are Major, Pentatonic or MinorBlues\n');
        return;
    end

    scalelength=length(C4s)*4+1;
    Scales=zeros(12,scalelength);
    Scales(1,:)=[C4s-24 C4s-12 C4s C4s+12 15]; % Extended C scale to 4 octaves
    for i=2:12
        Scales(i,:)=Scales(1,:)+i-1; % Extend to all other tonalities
    end
    ScaleFreq=f0*2.^(Scales/12);
    
    % Define in which key the sequence is
    for i=1:length(ScaleNames)
        if cellfun(@strcmp,Key,ScaleNames(i))
            ScaleChoice=i;
        end
    end
    % Define whether key signature is flats (1) or sharps (0)
    FlatsNames={'C','Db','Eb','F','Gb','Ab','Bb'};
    Flats=0;
    for i=1:length(FlatsNames)
        if cellfun(@strcmp,Key,FlatsNames(i))
            Flats=1;
        end
    end
        
    strt=LowestSeq;
    stop=strt+SeqLength;
    while Scales(ScaleChoice,stop)<=4
        strt=strt+length(C4s);
        stop=stop+length(C4s);
    end
    NewScale=Scales(ScaleChoice,strt:stop);
    NewFreq=ScaleFreq(ScaleChoice,strt:stop);
    NewArray=strings(1,11);
    for i=1:length(NewScale)
        NewArray(i)=string(midi2abc(NewScale(i)+69,Flats));
    end
    
    yMin = min(yData);
    yMax = max(yData);
    if IPmethod==1 % frequency
        InterpFreq=(yData-yMin)*(NewFreq(end)-NewFreq(1))/(yMax-yMin)+NewFreq(1);
        InterpNotes=round((log(InterpFreq)-log(f0))*12/log(2));
    elseif IPmethod==2 % log(frequency)
        InterpFreq=(yData-yMin)*(log(NewFreq(end))-log(NewFreq(1)))/ ...
            (yMax-yMin)+log(NewFreq(1));
        InterpNotes=round((InterpFreq-log(f0))*12/log(2));
    end
    if IPmethod<=2
        closestVals = round(interp1(NewScale, NewScale, InterpNotes, 'nearest'));
        [~, ScaleIndices] = ismember(closestVals, NewScale);
    else % equidistant notes
        ScaleIndices = round(1 + (yData - yMin) / (yMax - yMin) * ...
            (length(NewScale) - 1));
        closestVals = NewScale(ScaleIndices);
    end
    
    
    % MIDI output
    M = zeros(length(yData),6);
    [~,locs] = findpeaks(yData);
    M(:,1) = 1;         % all in track 1
    M(:,2) = 1;         % all in channel 1
    M(:,3) = closestVals+69;      % note numbers (69 is A4)
    M(:,4) = zeros(length(yData),1)+80;  % lets have volume at 80
    M(locs,4) = 120; % set accents for peaks in sequence
    M(:,5) = (0:0.25:0.25*(length(yData)-1))';  % note on:  notes start every .25 seconds
    M(:,6) = M(:,5)+0.25;   % note off: each note has duration .25 seconds
    midi=matrix2midi(M);
    midifile=[FileName, '.mid'];
    writemidi(midi, midifile);
    midifile=[FileName, '.mat'];
    save(midifile, 'M');

    % ABC output
    command=[FileName, '.abc'];
    outfile=fopen(command,'w');
    fprintf(outfile,'X: 1\nT: %s\nM: 4/4\nL: 1/4\nK: %s\n', ...
        string(FileName),string(Key));
    cnt=0;
    for i=1:Lines
        for j=1:maxj
            for k=1:4
                cnt=cnt+1;
                fprintf(outfile,'%s',NewArray(ScaleIndices(cnt)));
            end
            fprintf(outfile,'|');
        end
        fprintf(outfile,'\n');
    end
    fclose(outfile);

    if flag==1
        command=['abcm2ps ', FileName];
        system(command);
        command=['ps2pdf Out.ps ', FileName, '.pdf'];
        system(command);
    end

    save toto;
end


