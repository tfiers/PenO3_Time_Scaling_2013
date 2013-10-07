function frames = make_frames(input, sample_rate, fps, overlap)
%MAKE_FRAMES Splits the input signal in overlapping frames.
    % input         nx1 audio signal.
    % sample_rate   E.g. 44100, which means that 44100 samples represent 1
    %               second.
    % fps           Frames per second. Determines in how many frames the
    %               input signal will be chopped and how long they will be.
    %               E.g. 10.
    % overlap       A value in (0,1). E.g. 0.5 means the frames will be
    %               overlapped for 50%.

    % Provide default argument values.
    if nargin == 0 % Number of arguments in.
        sample_rate = 44100;
        fps = 10;
        overlap = 0.5;
    end

    % Break into pieces.
    frame_size = floor(sample_rate / fps); % FT is faster with powers of 2. ML function "nextPowersOf2"
    time_shift = floor(frame_size * overlap); % Sa in the assignment document.
                                              % Samples between each new
                                              % frame.
    num_frames = floor(size(input, 1) / time_shift);
    frames = zeros(num_frames, frame_size); % This is the eventual output.
                                            % Preallocate this large array for speed.
    % Populate all now-zero rows of frames.
    for frame_number = 1:num_frames
        offset_from_start = (frame_number-1)*time_shift+1; % -1 +1 to start with input(1:...)
        if offset_from_start+frame_size-1 < size(input, 1)
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