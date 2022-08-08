function ord_prod = eval_ord_prod(o,y,alg)
% evaluate ordinal label probabilities

ord_prod = 1;
for i = 1:size(y,1)
    y1 = y(i,:)';
    ord_like = ordinal_likelihood(alg,y1,o(i));
    ord_prod = ord_prod .* ord_like;
end

end

%% Compute individual ordinal likelihoods

function ord_likelihood  = ordinal_likelihood(alg,y,label)

ord_noise = alg.settings.gp_settings.ord_noise;
b = alg.settings.gp_settings.ordinal_thresholds;
%if label = 1, then b_yi = b1; b_(yi-1)= b0 ---> matlab 1-indexing --> hence
%b(yi + 1) and b(yi) instead.
% here y = f(x_i) --> the objective value
if numel(label) > 1 % y should be M by 1
    y_shape = size(y);
    z1 = ((repmat(b(label+1),y_shape(1),y_shape(2)) -  y)./ord_noise)';
    z2 = ((repmat(b(label),y_shape(1),y_shape(2)) -  y)./ord_noise)';
else
    z1 = (b(label+1) -  y)./ ord_noise;
    z2 = (b(label) -  y)./ ord_noise;
end
switch alg.settings.gp_settings.linkfunction
    case 'sigmoid'
        ord_likelihood = sigmoid(z1) -sigmoid(z2);
        ord_likelihood(ord_likelihood == 0) = 10^(-100);
    case 'gaussian'
        ord_likelihood = normcdf(z1) -normcdf(z2);
end
end

function out = sigmoid(x)
% Evaluates the sigmoid function at x
out = 1./(1 + exp(-x));

% if x is -inf -> derivative is zero
out(x <= -Inf) = 0;
end

