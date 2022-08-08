function obj = ObjectiveFunction(~, action)

% 6 dimensional Hartmann function: https://www.sfu.ca/~ssurjano/hart6.html

%%%% NOTE: objective function is negated so that finding the maximum is
%%%% equivalent to finding the minimum

alpha = [1.0 1.2 3.0 3.2]';
A = [10 3 17 3.50 1.7 8; ...
    0.05 10 17 0.1 8 14; ...
    3 3.5 1.7 10 17 8; ...
    17 8 0.05 10 0.1 14];
P = 10^(-4)*[1312 1696 5569 124 8283 5886; ...
    2329 4135 8307 3736 1004 9991; ...
    2348 1451 3522 2883 3047 6650; ...
    4047 8828 8732 5743 1091 381];

% initialize outputs
num_objs = size(action,1);
obj = zeros(num_objs,1);

% calculate objective function for each action in input
for d = 1:num_objs
    tempobj = 0;
    for i = 1:4
        expTerm = 0;
        for j = 1:6
            expTerm = expTerm - (A(i,j)*(action(d,j)-P(i,j))^2);
        end
        tempobj = tempobj - (alpha(i)*exp(expTerm));
    end
    obj(d) = -tempobj;
end


end

