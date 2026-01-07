function abc_note = midi2abc(midi_pitch,scale)
    % Map a single MIDI pitch value (0-127) to ABC notation string.
    % Adjust for key signatures based on the scale
    
    % Define note names based on a C scale
    if scale==1
        note_names = {'C', '_D', 'D', '_E', 'E', 'F', '#F', 'G', '_A', 'A', '_B', 'B'}; % flats
    else
        note_names = {'C', '#C', 'D', '#D', 'E', 'F', '#F', 'G', '#G', 'A', '#A', 'B'}; % sharps
    end
    
    % Calculate the pitch class (0-11, C to B)
    pitch_class = mod(midi_pitch, 12);
    
    % Calculate the octave number (MIDI standard: C4 is middle C, note 60)
    % The formula midi_pitch / 12 - 1 is often used for general music theory,
    % but for ABC notation, we define the "base" octave for mapping.
    % ABC's base octave uses capital letters C-B for MIDI notes 60-71.
    
    % Octave 5 starts at MIDI note 60. General octave calculation:
    octave = floor(midi_pitch / 12) - 1;

    % Get the basic note name (e.g., 'C', 'D#')
    base_name = note_names{pitch_class + 1};
    
    % --- Apply ABC Notation Octave Rules ---
    abc_note = '';
    
    if octave >= 5 % Middle C (note 60) and above
        % Use capital letters for Octave 5 (C5-B5)
        % Add apostrophes (') for each octave above Octave 5
        if octave == 5
            % Convert to lowercase
            base_name_lower = lower(base_name);
            abc_note = base_name_lower;
        else
            % Example: Octave 6 (C6) adds one ' -> C'
            % Octave 7 (C7) adds two ' -> C''
            apostrophes = repmat('''', 1, octave - 5);
            base_name_lower = lower(base_name);
            abc_note = [base_name_lower, apostrophes];
        end
    else % Below Middle C
        % Use lowercase letters for Octave 4 (c-b)
        % Add commas (,) for each octave below Octave 4
        if octave == 4
            % Convert to lowercase
            abc_note = base_name;
        else
            % Example: Octave 3 (c,) adds one ,
            % Octave 1 (c,,) adds two ,,
            commas = repmat(',', 1, 4 - octave);
            abc_note = [base_name, commas];
        end
    end
    
    % Handle accidentals for ABC notation
    % # becomes ^, so C# becomes ^C
    % ABC notation typically uses ^ (sharp) and _ (flat) prefixes.
    abc_note = strrep(abc_note, '#', '^'); 
    
    % You might also need to handle flats, e.g., Db is represented as _D
    % This example focuses on sharps/naturals for simplicity.
end

