function objective = power_objective(power)
%POWER_OBJECTIVE Vectorized total power; N-by-5 input, N-by-1 output.
validateattributes(power, {'numeric'}, {'2d','ncols',5,'real','finite','positive'});
objective = sum(power,2);
end
