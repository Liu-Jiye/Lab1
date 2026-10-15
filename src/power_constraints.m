function [constraint, equalityConstraint, sinrValue] = power_constraints(power)
%POWER_CONSTRAINTS SINR constraints for one candidate solution.
%
% Input:
%   power               - 1-by-5 vector containing one power allocation.
%
% Outputs:
%   constraint          - 1-by-5 vector; feasible when every entry <= 0.
%   equalityConstraint  - Empty vector (there are no equalities).
%   sinrValue           - 1-by-5 vector containing the five link SINRs.
%
% The nonlinear inequalities are written as
%   inverseSINR_i - 1/SINR_min <= 0.
% The bounds 0.1 <= P_i <= 5 are handled by the GA representation/repair.
%
% Teaching note:
%   This starter function intentionally handles only ONE candidate and uses
%   loops. In Lab 2, modify it to accept an N-by-5 population and return an
%   N-by-5 constraint matrix using population-level matrix operations.

    if ~isvector(power) || numel(power) ~= 5
        error('power_constraints:InputSize', ...
              'The input must be a 1-by-5 power vector.');
    end
    power = reshape(power, 1, 5);

    if any(~isfinite(power))
        error('power_constraints:NonFiniteInput', ...
              'The power vector contains NaN or Inf.');
    end

    noisePower = 0.5 * ones(1, 5);
    minimumSINR = 2;
    pathGain = [1.0  0.1  0.2  0.1  0.0; ...
                0.1  1.0  0.1  0.1  0.0; ...
                0.2  0.1  2.0  0.2  0.2; ...
                0.1  0.1  0.2  1.0  0.1; ...
                0.0  0.0  0.2  0.1  1.0];

    constraint = zeros(1, 5);
    equalityConstraint = [];
    sinrValue = zeros(1, 5);

    for receiver = 1:5
        interference = noisePower(receiver);

        for transmitter = 1:5
            if transmitter ~= receiver
                interference = interference ...
                    + pathGain(receiver, transmitter) * power(transmitter);
            end
        end

        desiredSignal = pathGain(receiver, receiver) * power(receiver);
        sinrValue(receiver) = desiredSignal / interference;
        inverseSINR = 1 / sinrValue(receiver);
        constraint(receiver) = inverseSINR - 1 / minimumSINR;
    end
end
