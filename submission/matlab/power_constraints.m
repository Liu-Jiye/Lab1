function [constraint,equalityConstraint,sinrValue] = power_constraints(power)
%POWER_CONSTRAINTS Vectorized inverse-SINR constraints for an N-by-5 population.
% Bounds are checked by evaluate_population and handled by the algorithms.
validateattributes(power, {'numeric'}, {'2d','ncols',5,'real','finite','positive'});
G = power_model();
interference = power*(G-diag(diag(G))).' + 0.5;
sinrValue = (power.*diag(G).')./interference;
constraint = 1./sinrValue - 0.5;
equalityConstraint = [];
end
