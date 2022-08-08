function out = sigmoid_der(x)
    % Evaluates the derivative of the sigmoid function at x
    
    out = exp(-x)./((1 + exp(-x)).^2);
    
    % if x is -inf -> derivative is zero 
    out(x <= -Inf) = 0;
end