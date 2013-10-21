function corr = correlation_only_shift_fwd(signal1, signal2, max_offset)
    % Calculates the cross correlation of the two given input signals via the formula
    % (1) given in the assignment document. This only shifts the second signal forward,
    % not backward.

    % signal1, signal2      'x_L1', 'x_L2' in (1). Should be vectors of equal length.
    % max_offset            By how many samples the second signal should be shifted forwards maximum.

    L = max(size(signal1));

    if nargin == 2
        max_offset = L;
    end

    corr = zeros(1, max_offset);
    for m = 1:max_offset
        corr(m) = sum(signal1(1:(L-m+1)) .* signal2(m:end)) / L;
    end
end
