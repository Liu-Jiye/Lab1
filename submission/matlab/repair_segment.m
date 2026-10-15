function Y = repair_segment(Y,parent)
%REPAIR_SEGMENT Clip bounds then retract toward a feasible parent.
% This is feasibility repair, not an optimizer: it never uses an objective,
% CVX, a stored optimum or a solved power allocation. Linear inequalities
% are algebraically equivalent to the original SINR bounds for positive P.
% Stop slightly inside the boundary to retain room for future variation.
Y = min(5,max(0.1,Y));
[~,A,b] = power_model();
slack = b.'-parent*A.';
step = (Y-parent)*A.';
ratios = slack./max(step,realmin);
ratios(step<=0) = Inf;
alpha = min(1,min(ratios,[],2));
alpha = max(0,alpha);
hit = alpha<1;
alpha(hit) = 0.98*alpha(hit);
Y = parent + alpha.*(Y-parent);
end
