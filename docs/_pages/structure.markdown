---
layout: page
title: Toolbox Structure
permalink: /structure/
---

POLAR is implemented as a MATLAB class 'polar_class'. To view the documentation for the class, run:
```
doc polar_class
```

In general, key features of the class are as follows:

To instanteate the class:
``` 
obj = polar_class(settings)
``` 
where settings is a structure that defines the desired action space and learning options. Examples of how to construct these settings are included in the setupLearning.m functions of each example in the examples folder.

To run a simulation based on a predefined underlying objective function:
```
obj.runSimulation(plottingFlag, saveFlag)
```
where plottingFlag is a flag to indicate if you would like plots to be generated after each iteration, and saveFlag is a flag to indicate if you would like the results of the simulation saved in the folder dictated by settings.save_folder

To run an experiment:
```
obj.runExperiment(plottingFlag,saveFlag)
```
where plottingFlag and saveFlag are the same as those in obj.runSimulation.



In the simulations, feedback is automatically generated using the following three functions:
```
feedback = obj.getSyntheticPreference_max(iteration);
coac_feedback = obj.getSyntheticCoactive_max(iteration);
ord_label = obj.getSyntheticOrdinalLabel(iteration);
```

In both runSimulation and runExperiment, the following functions are used:
```
obj.getNewActions(iteration);
obj.addFeedback(preferences,suggestions,ordlabels,iteration);
```

If you would like to execute validation trials after collecting user feedback, you can enter a 'validation phase' using the function
```
obj.enterValidationPhase(obj,model);
```

The available plotting functions are the following:
```
obj.plotTrueObjective 
obj.plotAll(coactive, sampled,isSave,iteration)
obj.plotFlattenedPosterior(isSave,iteration)
obj.plotObjective(isSave,iteration)
obj.obj.plotRegret
obj.plotCoactive(isSave,iteration)
obj.plotLabelAccuracy(isSave,iteration)
obj.plotSampledActions(isSave,iteration)
```

Lastly, the function to visualize the effect of the chosen lengthscales is:
```
obj.testLengthscales
```