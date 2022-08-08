function obj = ObjectiveFunction(~,action)

% 6 dimensional Hartmann function: https://www.sfu.ca/~ssurjano/hart6.html

%%%% NOTE: objective function is negated so that finding the maximum is
%%%% equivalent to finding the minimum

alpha = [1.0 1.2 3.0 3.2]';
A = [3 10 30; ...
    0.1 10 35; ...
    3.0 10 30; ...
    0.1 10 35];
P = 10^(-4)*[3689 1170 2673; ...
            4699 4387 7470; ...
            1091 8732 5547; ...
            381 5743 8828];

% initialize outputs
num_actions = size(action,1);
obj = zeros(num_actions,1);

% calculate objective function for each action in input
for d = 1:num_actions
    tempobj = 0;
    for i = 1:4
        expTerm = 0;
        for j = 1:3
            expTerm = expTerm - (A(i,j)*(action(d,j)-P(i,j))^2);
        end
        tempobj = tempobj + (alpha(i)*exp(expTerm));
    end
    obj(d) = tempobj;
end


end

