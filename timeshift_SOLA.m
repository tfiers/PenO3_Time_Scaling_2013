function timeshifted_signal = timeshift_SOLA(filename, sample_rate, overlap, fps, alpha)
    % Speeds up/slows down audio with Synchronisation, Overlap and Add (SOLA) (with crossfade).
    
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

    
    tic % For measuring how long this function took to complete.
    
    % Provide default argument values.
    if nargin == 0 % Number of arguments in.
        filename = 'Speech Materials\goedele1.wav';
        sample_rate = 44100;
        overlap = 0.5;
        fps = 10;
        alpha = 1.5;
    end

    input = audioread(filename); % Load audio file.
    input_left = input(:, 1); % Split channels (for stereo audio)
    input_right = input(:, 2); % We assume the input is nx2.
    % It could be that the left signal is in the second row, of course.
    
    % (For later reference:)
    % Y = resample(input, 2, 1); % resample at half the speed
    % player = audioplayer(input, sample_rate);  %player element, easy to play/pause sound
    
    % Chop the input signals into overlapping frames.
    % framesl/framesr have dimensions num_frames:frame_size
    frames_left = make_frames(input_left, sample_rate, overlap, fps);
    frames_right = make_frames(input_right, sample_rate, overlap, fps);
    frame_size = size(frames_left, 2);


    % Recombine frames with a time shift.

    % This will be our eventual output signal.
    % It's dimensions during construction will be 2xn.
    % We already put in the first frame.
    % (To cut some more milliseconds from execution time, this matrix should
    %  be preallocated with zeros.)
    timeshifted_signal = [frames_left(1,:); frames_right(1,:)];
    % After 'time_shift' samples in the output signal, a new frame begins.
    % 'Ss' in the assignment document.
    % (1-overlap) gives 0.8 for an overlap of e.g. 0.2
    % For there to be no gaps in the output signal, time_shift should be smaller than frame_size,
    % or: alpha * frame_size * (1-overlap) < frame_size
    % or: alpha < 1 / (1-overlap)
    time_shift = round(alpha * frame_size * (1-overlap));
    % Add all remaining frames one by one to the output signal.
    for i = 2:size(frames_left,1)
        % Select i'th row in framesl/framer = i'th frame.
        framel = frames_left(i,:);
        framer = frames_right(i,:);
        % 'index1' is the index in the output signal where the overlap with the next-to-be-added frame (framel/framer) starts.
        index1  = (i-1) * time_shift;
        % 'index2' is the index of the last sample in the output singal, where the overlap stops of course.
        index2 = size(timeshifted_signal, 2);

        % Synchronising the existing output and the new frame.

        LOWEST_HUMAN_FUNDAMENTAL_FREQUENCY = 300; % Hz.
        % Equals half a period of the lowest fundemental of the human voice. 
        % (147 for sampling rate of 44100)
        maximum_offset = ceil(sample_rate / LOWEST_HUMAN_FUNDAMENTAL_FREQUENCY / 2);

        % The largest found value of the correlation function...
        max_correlation = -inf;
        % ... and it's index.
        max_correlation_index = 0;
        % The length of the overlap of the new frame with the existing output signal
        % when the correlation is maximum.
        max_correlation_length_overlap = 0;

        % Evaluate cross correlation function (eq. 1 in assignment document) for each point of the overlap.
        % We start by shifting the new frame to the left by 'maximum_offset'
        % 'j' is k_m in the assignment document.
        for j = -maximum_offset:maximum_offset
            % Index in the already constructed output signal where the cross-correlation starts.
            index0 = index1+j;
            % The sample at index0 itself is also overlapping, thus + 1
            length_overlap = index2 - index0 + 1;
            overlapping_part_of_output_signal = timeshifted_signal(1, index0:index2);
            % (We work with the left audio siganl for correlation.)
            overlapping_part_of_frame = framel(1, 1:length_overlap);
            % Number saying how well the new frame (shifted by j) and the existing output signal overlap:
            % Throughs on throughs / valleys on valleys make positive values, while
            % valleys and througs make negative values (both proportional to amplitude).
            correlation = sum(overlapping_part_of_output_signal .* overlapping_part_of_frame) / length_overlap;
            % Look for the maximum correlation by comparing the current correlation value with the current maximum.
            if correlation > max_correlation
                max_correlation = correlation;
                max_correlation_index = j;
                max_correlation_length_overlap = length_overlap;
            end
        end

        % Index in the already constructed output signal where the cross-correlation is maximum.
        index0 = index1 + max_correlation_index;

        % Generate a vector linearly decreasing from 1 to 0.
        fade_out = linspace(1, 0, max_correlation_length_overlap);
        % Generate a vector linearly increasing from 0 to 1.
        fade_in = linspace(0, 1, max_correlation_length_overlap);
        % Sum up the overlapping samples of the output signal and the new frames, 
        % weighted by respectively the fade_in and fade_out vectors.
        timeshifted_signal(1:2, index0:index2) = timeshifted_signal(1:2, index0:index2) .* [fade_out; fade_out] ...
                                                 + [framel(1:max_correlation_length_overlap); framer(1:max_correlation_length_overlap)] .* [fade_in; fade_in];                                
        % Add the rest of the samples of framel/framer to the output (those samples do not overlap). 
        timeshifted_signal = [timeshifted_signal, [framel(max_correlation_length_overlap+1:end); framer(max_correlation_length_overlap+1:end)]];
    end

    % Transpose output signal to match dimensions of input signal.
    timeshifted_signal = timeshifted_signal';

    toc
end
