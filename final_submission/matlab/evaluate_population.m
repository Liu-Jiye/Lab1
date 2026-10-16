function [F,C,S,V,feasible] = evaluate_population(X,margin)
%EVALUATE_POPULATION Joint evaluation, with strict final feasibility.
% MOEA/D optionally uses an inward margin against scalar/batch roundoff.
% Each row counts as ONE evaluation of the problem, regardless of outputs.
if nargin<2, margin=0; end
[C,~,S] = power_constraints(X);
F = [power_objective(X), -sum(log2(1+S),2)];
V = sum(max(C,0),2)+sum(max(0.1-X,0)+max(X-5,0),2);
feasible = all(C<=-margin,2) & all(X>=0.1 & X<=5,2);
end
