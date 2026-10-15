function objective = power_objective(power)
%POWER_OBJECTIVE Total transmitter power for one candidate solution.
%
% Input:
%   power      - 1-by-5 vector containing one candidate power allocation.
%
% Output:
%   objective  - Scalar total transmitter power.
%
% Teaching note:
%   This starter function intentionally handles only ONE candidate and uses
%   a loop. In Lab 2, modify it to accept an N-by-5 population and return
%   an N-by-1 vector using population-level matrix operations.

    if ~isvector(power) || numel(power) ~= 5
        error('power_objective:InputSize', ...
              'The input must be a 1-by-5 power vector.');
    end
    power = reshape(power, 1, 5);

    if any(~isfinite(power))
        error('power_objective:NonFiniteInput', ...
              'The power vector contains NaN or Inf.');
    end

    objective = 0;

    for transmitter = 1:5
        objective = objective + power(transmitter);
    end
end
