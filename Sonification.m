function [ScaleIndices,NewFreq] = Sonification(yData,LowestSeq,Key, ...
    SeqLength,FileName,IPmethod,flag)

% Function that transforms any dataseries (preferably a multiple of 8 or 16
% data points) into a musical sequence.
%
% INPUT
% yData       =  one-dimensional vector containing numeric (eral) data
% StartingSeq =  note in the chosen scale on which to start the sequence (1-7)
% Key         =  major key of the sequence (C, Db, D, Eb, ...)
% SeqLength   =  tonal span of the sequence (14 = 2 octaves)
% FileName    =  name of outputfile (without extension)
% IPmethod    =  mapping method: 1: frequency; 2: logarithmic frequency
%                  (linear scale); 3: equidistant
% flag        =  0: only abc output file is created
%                1: abc software and ps2pdf is executed to produce a pdf
%                   file with sheet music
%
% OUTPUT
% Text file written with musical written in abc notation
% (https://abcnotation.com/). The file has the extension '.abc'
% If 'flag=1', the abc2ps programme will be executed and a pdf file created
% with the sheet music. This requires installation of the abc notation
% software as well as ghostscript and ps2pdf.
% Alternatively the .abc file can be transformed into sheet music using
% online abc tools (see https://abcnotation.com/ for more info).
%
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
    C4s=[-9 -7 -5 -4 -2 0 2]; % Standard C4 to C5 scale, with A4 = 0

    Scales=zeros(12,29);
    NewString=strings(12,29);
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
    
    % abc notation corresponding to matrix Scales
    strCell = {'C,,','D,,','E,,','F,,','G,,','A,,','B,,', ...
        'C,','D,','E,','F,','G,','A,','B,', ...
        'C','D','E','F','G','A','B', ...
        'c','d','e','f','g','a','b', ...
        'c''','d''','e''','f''','g''','a''','b'''};
    strArray=string(strCell);
    
    ScaleStart=[1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7];
    for i=1:12
        NewString(i,:)=strArray(ScaleStart(i):ScaleStart(i)+28); % Extend to all other tonalities
    end
    
    strt=LowestSeq;
    stop=strt+SeqLength;
    while Scales(ScaleChoice,stop)<=4
        strt=strt+7;
        stop=stop+7;
    end
    NewScale=Scales(ScaleChoice,strt:stop);
    NewFreq=ScaleFreq(ScaleChoice,strt:stop);
    NewArray=NewString(ScaleChoice,strt:stop);

    yMin = min(yData);
    yMax = max(yData);
    if IPmethod==2 % log(frequency)
        InterpFreq=(yData-yMin)*(log(NewFreq(end))-log(NewFreq(1)))/ ...
            (yMax-yMin)+log(NewFreq(1));
        InterpNotes=round((InterpFreq-log(f0))*12/log(2));
    elseif IPmethod==1 % frequency
        InterpFreq=(yData-yMin)*(NewFreq(end)-NewFreq(1))/(yMax-yMin)+NewFreq(1);
        InterpNotes=round((log(InterpFreq)-log(f0))*12/log(2));
    end
    if IPmethod<=2
        closestVals = round(interp1(NewScale, NewScale, InterpNotes, 'nearest'));
        [~, ScaleIndices] = ismember(closestVals, NewScale);
    else % equidistant notes
        ScaleIndices = round(1 + (yData - yMin) / (yMax - yMin) * ...
            (length(NewScale) - 1));
    end

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

end


