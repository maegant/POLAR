function [objectives] = ObjectiveFunction(~,action)
% Important: action must be nxdim where n is the number of actions being
% evaluated and dim is the dimensionality of each action

% Description of Objective Function:
%   Univariate multimodal function

% calculate objective function for each action in input
objectives = -exp(-action(:,1)).*sin(2*pi*action(:,1));

% calculate gradient of objective function for each action in input
gradients = exp(-action(:,1)).*(sin(2*pi*action(:,1))-(2*pi*cos(2*pi*action(:,1))));


end

