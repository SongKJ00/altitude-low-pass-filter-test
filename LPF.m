function [ filterX ] = LPF( alpha, prevFilterX, x )
%
%
    filterX = alpha * prevFilterX + (1.0 - alpha) * x;
end

