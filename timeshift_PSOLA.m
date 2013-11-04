function timeshifted_signal = timeshift_PSOLA(filename, sample_rate, overlap, fps, alpha)
    % Speeds up/slows down audio with Pitch-Synchronous Overlap and Add (SOLA).
    
    % filename      A string giving the absolute or relative path of a .wav
    %               file. E.g. 'Speech Materials\annelies1.wav' or
    %               'C:\annelies1.wav'.
    % sample_rate   E.g. 44100, which means that 44100 samples represent 1
    %               second.
    % overlap       A value in (0,1). 0.2 for example means that when the input
    %               signal is broken into frames, they will overlap for 20%.
    % fps           Frames per second. Determines in how many frames the
    %               input signal will be chopped and how long the frames will be.
    %               E.g. 10.
    % alpha         A value in (0,2) that determines the amount of time
    %               stretching. alpha in (0,1) speeds up the signal, alpha
    %               in (1,2) slows it down. Alpha must be smaller than 1/(1-overlap),
    %               (else there would be gaps in the output signal.)
    %               (See in code, at definiton of 'time_shift' for explanation.)
    
    % Provide default argument values.
    if nargin == 0 % Number of arguments in.
        filename = 'Speech Materials/goedele1.wav';
        sample_rate = 44100;
        overlap = 0.5;
        fps = 10;
        alpha = 1.5;
    end
    
    %Determins the band size to look at while looking for a maximum to
    %avoid the effects of outliers.
    MARGIN_OF_ERROR_FOR_MAXIMUM = 2;
    
    input = audioread(filename); % Load audio file.
    input_left = input(:, 1); % Split channels (for stereo audio)
    input_right = input(:, 2); % We assume the input is nx2.
    % It could be that the left signal is in the second row, of course.
    
    % Chop the input signals into overlapping frames.
    % framesl/framesr have dimensions num_frames:frame_size
    frames_left = make_frames(input_left, sample_rate, overlap, fps);
    frames_right = make_frames(input_right, sample_rate, overlap, fps);
    number_of_frames = size(frames_left, 1);
    frame_size = size(frames_left, 2);
    
    % Pitch detection per frame. (Only on the right frame for now.)(Needs
    % optimization!)
    for i=1:number_of_frames
        pitch(i,1) = autoCorrelation(frames_right(i,:), sample_rate);
        
        %Look for maximum value as that's definately a peak.
        max_average_value_index = 1+MARGIN_OF_ERROR_FOR_MAXIMUM;
        max_average_value_till_now = sum(frames_left(i,1:1+2*MARGIN_OF_ERROR_FOR_MAXIMUM))/(1 + 2*MARGIN_OF_ERROR_FOR_MAXIMUM);
        
        for j=1+MARGIN_OF_ERROR_FOR_MAXIMUM:frame_size-MARGIN_OF_ERROR_FOR_MAXIMUM
            average_value = sum(frames_left(i,j-MARGIN_OF_ERROR_FOR_MAXIMUM:j+MARGIN_OF_ERROR_FOR_MAXIMUM))/(1 + 2*MARGIN_OF_ERROR_FOR_MAXIMUM);
            if average_value > max_average_value_till_now
                max_average_value_till_now = average_value;
                max_average_value_index = j;
            end
        end
        
        %Define upcoming peaks
        for j=max_average_value_index:sample_rate/pitch(i,1):frame_size
            
        end
        %Define previous peaks
        for j=max_average_value_index:-sample_rate/pitch(i,1):1
        end
        
    end
    
    %Define pitchmarks
    
    
end

