function pref_prod = eval_pref_prod(s,y_pref,alg)
% evaluate preference feedback probabilities

pref_prod = 1;

%y_pref = R(comp_pref_idx,:) % 5 x 500 x 2
for i = 1:size(y_pref,1)
    y1 = squeeze(y_pref(i,:,:));
    pref_like = preference_likelihood(alg,y1,s(i));
    pref_prod = pref_prod .* pref_like;
end

end

%% Compute individual preference likelihoods

function pref_likelihood  = preference_likelihood(alg,y,label)

pref_noise = alg.settings.gp_settings.pref_noise;
y_shape = size(y);
if length(y_shape) > 2 % y should be a 3d array: action_comb by M by 2
    y_flatten = reshape(y,y_shape(1) * y_shape(2),2);
    z_flatten = (y_flatten(:,label) - y_flatten(:,3 - label)) ./ pref_noise;
    z = reshape(z_flatten,y_shape(1),y_shape(2));
else
    z = (y(:,label) - y(:,3 - label)) ./ pref_noise;
end


switch alg.settings.gp_settings.linkfunction
    case 'sigmoid'
        pref_likelihood  = sigmoid(z);
    case 'gaussian'
        pref_likelihood = normcdf(z./sqrt(2));
end

end

function out = sigmoid(x)
% Evaluates the sigmoid function at x
out = 1./(1 + exp(-x));

% if x is -inf -> derivative is zero
out(x <= -Inf) = 0;
end

