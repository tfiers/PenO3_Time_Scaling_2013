function frames = make_frames(input, sample_rate, overlap, fps)
%MAKE_FRAMES Splits the input signal in overlapping frames.
    % input         nx1 audio signal.
    % sample_rate   E.g. 44100, which means that 44100 samples represent 1
    %               second.
    % overlap       A value in (0,1). 0.2 for example means that when the input
    %               signal is broken into frames, they will overlap for 20%.
    % fps           Frames per second. Determines in how many frames the
    %               input signal will be chopped and how long the frames will be.
    %               E.g. 10.

    % Provide default argument values.
    if nargin == 1 % Number of arguments in.
        sample_rate = 44100;
        overlap = 0.5;
        fps = 10;
    end

    % Number of samples in one frame.
    frame_size = floor(sample_rate / fps); % FFT is faster with powers of 2. 
                                           % There's a ML function like "nextPowerOf2"
    % Sa in the assignment document.
    % Samples between each new frame.
    % (1-overlap) gives 0.8 for an overlap of e.g. 0.2
    time_shift = frame_size * (1-overlap);
    % Number of frames we will make. Number of rows in the output matrix.
    num_frames = round(size(input, 1) ./ time_shift);
    % This is the eventual output.
    % Preallocate this large (with zeros) array for speed.
    frames = zeros(num_frames, frame_size); 
    % Populate the output matrix 'frames' row by row (which are currently all zeros).
    for frame_number = 1:num_frames
        % The sample in the input signal where our next frame starts.
        % We do -1 +1 to start with input(1:...)
        % So for a time_shift of 4410, we'll get 1, 4411, 8821, ...
        offset_from_start = round((frame_number-1)*time_shift+1);
        % Check whether there are enough samples left in the input signal to fill a whole frame.
        if offset_from_start+frame_size <= size(input, 1)
            % Overwrite zeros in new row with next frame.
            frames(frame_number, :) = input(offset_from_start:offset_from_start+frame_size-1, 1);
        else
            % Partially overwrite the last row, because the last part of
            % the input signal does not contain a whole frame worth of
            % samples.
            num_zeros = size(input(offset_from_start:end,1));
            frames(frame_number, 1:num_zeros) = input(offset_from_start:end, 1);
        end
    end
end
