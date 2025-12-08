function SonifExample1

% Example that transforms the ENSO dataseries into a musical sequence,
% using the Sonification function
% F. Pattyn - ULB
% 2025

% Output written with abc notation: https://abc.rectanglered.com/

    clear;
    close all;

% In this example, the Key is B flat major (BbM7), resulting in B flat and
% E flat as key signatures. The key is similar to C minor 7 (Cm7), so if
% you want a minor key, you need to provide the key of the associated major
% scale with the same key signatures. The lowest note is C3, which is the
% second note in the sequence of Bb. The sequence spans 14 notes, which is
% equivalent to two octaves, in this case from C3 to C5. The output is a
% file named ENSO.abc, which contains abc notation. Its content is the
% following:
%
% X: 1
% T: Sonification
% M: 4/4
% L: 1/4
% K: Bb
% aABf|GeaD|CcAc'|EAFc|
% ABdB|FBGD|Gdfd|GEBa|
%
% Using online tools it is possible to write this out as sheet music (pdf
% file), as well as audition. Many different free tools are available on 
% https://abc.rectanglered.com/

    sequence=32; % Length of the sequence (16,32,64, ...)
    lowest=2; % Note in scale on which to start the sequence (1-7)
    key={'Bb'}; % 12 keys to chose from (no sharps, only flats)
    span=14; % Tonal span of the sequence (14 = 2 octaves)
    fs = 44100;
    duration=1/4; % 1/4 notes @ 90 bpm = 1/6
    abc=1; % Use locally installed abc program to make a PDF file with sheet
           % music. (1 or 0)

    % Read data set where x and y values are in the first two columns
    data=load('ENSOdata.txt');
    % Interpolate the time sequence to the sepcified number of steps definied
    % by sequence
    signal=Data2Music(data,data(1,1),data(end,1),sequence,lowest, ...
        key,span,fs,duration,'ENSO',abc);

    for i=1:2
        % Play the combined signal
        sound(signal, fs);
        pause(sequence*duration+0.55);
    end
    
end


