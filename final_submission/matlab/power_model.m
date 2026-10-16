function [G,A,b] = power_model()
%POWER_MODEL Receiver-by-transmitter gains and equivalent linear SINR bounds.
G = [1 .1 .2 .1 0; .1 1 .1 .1 0; .2 .1 2 .2 .2; .1 .1 .2 1 .1; 0 0 .2 .1 1];
% SINR >= 2 iff (2*offdiag(G)-diag(diag(G)))*P <= -1.
A = 2*(G-diag(diag(G)))-diag(diag(G));
b = -ones(5,1);
end
