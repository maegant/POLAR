function out = sigmoid_der2(x)
    % Evaluates the 2nd derivative of the sigmoid function at x
    
    out = (-exp(-x) + exp(-2.*x))./((1 + exp(-x)).^3);
    
    % if x is -inf -> derivative is zero 
    out(x <= -Inf) = 0;
end