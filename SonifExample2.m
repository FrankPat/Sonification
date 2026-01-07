function SonifExample2

% Example that transforms the ENSO dataseries into a musical sequence,
% using the Sonification function
% F. Pattyn - ULB
% 2025

% Output written with abc notation: https://abc.rectanglered.com/

    clear;
    close all;

% In this example, the Key is F major (FM7), resulting in B flat as 
% key signatures. The key is similar to G minor 7 (Gm7), so if
% you want a minor key, you need to provide the key of the associated major
% scale with the same key signatures. The starting note is G, which is the
% second note in the sequence of F. The sequence spans 14 notes, whic is
% equivalent to two octaves, in this case from G3 to G5.
% In this particular example, two sequences are generated, one representing
% the ice mass change of the Antarctic ice sheet and one of the Greenland
% ice sheet. Both span a time series from 1992 to 2018 and are taken from
% imbie.org. The y-data are reversed, meaning that a high pitch leads to
% more mass loss (which originally is taken as a negative value).

    sequence=32; % Length of the sequence (16,32,64, ...)
    lowest=2; % Note in scale on which to start the sequence (1-7)
    key={'F'}; % 12 keys to chose from (no sharps, only flats)
    span =14; % Tonal span of the sequence (14 = 2 octaves)
    IPmethod=2; % Interpolation method (1-3)
    scale={'Major'};
    abc=1; % Write output on pdf file using abc software

    data=load('ImbieAntarctica.txt');
    data(:,2)=-data(:,2);
    Data2Music(data,1992,2018,sequence,lowest, ...
        key,span,'AIS',IPmethod,scale,abc);

    pause(10);
    
    data=load('ImbieGreenland.txt');
    data(:,2)=-data(:,2);
    Data2Music(data,1992,2018,sequence,lowest, ...
        key,span,'GrIS',IPmethod,scale,abc);
    
end


