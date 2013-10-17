% function [offsets, correlation] = correlation(signal1, signal2, maximum_offset)
%     % Row vector containing the x-axis values of the correlation function.
%     offsets = -maximum_offset:maximum_offset;
%     % Number of values (offsets) for which the correlation function is evaluated.
%     num_offsets = max(size(offsets));
%     % Row vector containing the correlation function.
%     correlation = zeros(1, num_offsets);
%     % Evaluate cross correlation function (eq. 1 in assignment document) for each point of the overlap.
%     % We start by shifting the new frame to the left by 'maximum_offset'
%     % 'j' is k_m in the assignment document.
%     % for j = 1:maximum_offset
%     %     % Number saying how well the new frame (shifted by j) and the existing output signal overlap:
%     %     % Throughs on throughs / valleys on valleys make positive values, while
%     %     % valleys and througs make negative values (both proportional to amplitude).
%     %     correlation(1, j) = sum(signal1(j:end) .* signal2(1:end-j));
%     % end
%     % for j = 1:maximum_offset
%     %     % Number saying how well the new frame (shifted by j) and the existing output signal overlap:
%     %     % Throughs on throughs / valleys on valleys make positive values, while
%     %     % valleys and througs make negative values (both proportional to amplitude).
%     %     correlation(1, maximum_offset+j+1) = sum(signal2(j:end) .* signal1(1:end-j));
%     % end

%     for i = 1:num_offsets
%         offset = offsets(i);

%     end
% end


function corr = correlation(signal1, signal2)
    % Calculates the cross correlation of the two given input signals via the formula
    % (1) given in the assignment document.

    % signal1, signal2      'x_L1', 'x_L2' in (1). Should be row-vectors.

    L = size(signal1, 1);
    corr = zeros(1, n);
    for m = 1:L
        corr(m) = sum(signal1(1:(L-m+1)) .* signal2(m:end)) / L;
    end
end
