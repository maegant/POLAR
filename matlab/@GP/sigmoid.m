function out = sigmoid(x)
    % Evaluates the sigmoid function at x
    
    out = 1./(1 + exp(-x));
    
    % if x is -inf -> derivative is zero 
    out(x <= -Inf) = 0;
end