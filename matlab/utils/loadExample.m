function alg = loadExample(exampleName)

rmpath(genpath('example'));
addpath(['example/',exampleName,'/']);
settings = setupLearning;

% instanteate learning algorithm object
alg = PBL(settings);
end