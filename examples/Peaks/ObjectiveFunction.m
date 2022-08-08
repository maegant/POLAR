function [objectives] = ObjectiveFunction(~,action)

% MATLAB peaks function
% z =  3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ... 
%    - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ... 
%    - 1/3*exp(-(x+1).^2 - y.^2) 

% compute objective values for actions
objectives = peaks(action(:,1),action(:,2));

x = action(:,1);
y = action(:,2);

% compute gradient in x dimension
gradients(:,1) = -(2/3)*exp(-x.^2 - 2*x - (y+1).^2).* ...
    (exp(2*x + 2*y + 1).*(30*x.^4 - 51*x.^2 + 30*x.*y.^5 + 3) ...
        + 9*exp(2*x).*(x.^3 - 2*x.^2 + 1) ...
        + (x + 1).*(-exp(2*y)));
    
% compute gradient in y dimension
gradients(:,2) = (1/3)*exp(-x.^2 - 2*x - (y+1).^2).* ...
    (-6*y.*exp(2*x + 2*y + 1).*(10*x.^3 - 2*x + 5*y.^3.*(2*y.^2 - 5)) ...
        - 18*exp(2*x).*(x-1).^2.*(y+1) + 2*exp(2*y).*y);

end

