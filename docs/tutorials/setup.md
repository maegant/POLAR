---
layout: default
title: Setting Up a New Experiment/Simulation
permalink: /new-environment/
parent: Tutorials
nav_order: 1
mathjax: true
---

In this tutorial we will go through how to setup a new experiment/simulation using the ``example_script.m`` MATLAB script. 

<details open markdown="block">
  <summary>
    Contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## Add POLAR to your path
The first step is to copy the ``example_script.m`` file to a new respository where you'd like to save your code. You can also keep the script inside of the POLAR repository. From wherever you save your new script, you will then need to add the POLAR repository to your path and setup the toolbox paths. To do this, define the location of your POLAR repository and run:
```
polar_path = $PATH;
addpath(polar_path);
toolbox_addpath;
``` 

## Define user settings
The second step is to define all of the necessary/optional user settings which will be included under obj.settings. We will go through some of the main settings here:

### Save folder: `settings.save_folder`
The POLAR algorithm exports learning results and figures to a user specified path/folder. This path/folder is defined as: `settings.save_folder`.


### Buffer size: `settings.b`
In each iteration, the user is asked for pairwise preferences between all combinations of new sampled actions with actions stored in a "Buffer". The buffer can be thought of as the actions that the user can reliably remember. We recommend setting the buffer size to 1 since users typically have difficulty remembering more than 1 action at a time. To set $$b = 1$$, define `settings.b = 1`.


### Number of actions to sample: `settings.n`
In each iteration, $$n$$ actions are sampled and then given to the user. For example, if $$n = 2$$, then 2 new actions will be sampled and executed on hardware during each iteration of the algorithm. Pairwise preferences are then generated between each combination of these actions, along with each combination between these actions and the buffer actions. We recommend setting $$ n = 1$$ and $$ b = 1$$. In situations where substantial time is required between obtaining an action to execute, and observing the experimental behavior of the action, we recommend setting $$ n = 2$$ and $$b = 0$$ since this allows actions to be processed in a batch, and executed on hardware back to back. If the user can reliably give a ranking between more than 2 actions, it is beneficial to set $$ n > 2 $$, however we typically don't recommend this since it can lead to noisy preference feedback. To set $$n = 1$$, define `settings.n = 1`.


### Acquisition method: `settings.sampling.type`
There are three options for sampling actions: 
1. Regret minimization: aimed at identifying the optimal action as quickly as possible
2. Active learning: aimed at learning the entire underlying utility function
3. Random sampling: for comparison purposes only (samples actions randomly)
You can select one of these three options by setting the following to either 1, 2, or 3. For example, to select regret minimiziation as the acquisition method, you would set `settings.sampling.type = 1`. For information on which learning objective you *should* select for your task, read the [Learning Frameworks]({{site.baseurl}}/frameworks/) page.

### Types of feedback to include: `settings.feedback.types`
There are three types of feedback available in POLAR: 
1. pairwise preferences
2. coactive feedback (user suggestions)
3. ordinal labels.
You can select any combination of these feedback types to include in the learning. For example, if you wanted to include pairwise preferences and ordinal labels you would define `settings.feedback.types = [1,3]`.  For more information on the different feedback types, visit the [Feedback Types]({{site.baseurl}}/feedback/) page.

### Dimensionality reduction: `settings.useSubset; settings.subsetSize; settings.defineEntireActionSpace; ` 
The POLAR framework allows you to choose if you would like to implement dimensionality reduction or not. For high dimensional action spaces (3-dimensional or more) we recommend setting `settings.useSubset = 1` to remain computationally tractable. The dimensionality reduction techniques limit the posterior inference to a subspace $$ \mathcal{S} \subset \mathcal{A}$$. If instead you would like to update the posterior over the entire action space $$ \mathcal{A} $$, you can elect to do this by setting `settings.useSubset = 0`. 

For active learning, $$ \mathcal{S}$$ is comprised of a random set of actions combined with the previously sampled actions. The number of random actions to include in $$ \mathcal{S} $$ is defined as  `settings.subsetSize`. We recommend setting `settings.subsetSize = 500` for most action spaces. Again, note that this is only required when `settings.sampling.type = 2`. 

For really high dimensional action spaces (6-dimensional or more), you may want to set `settings.defineEntireActionSpace = 1` which eliminates the computation of the entire action space but limits some of the plotting capabilities.


### Simulation settings 
If you would like to simulate the learning performance using synthetically generated feedback for a given utility function, there are a few additional settings required. The first is the number of iterations to simulate. For example, if you would like to simulate the learning performance for 100 iterations, you would set `settings.maxIter = 100`. 

The additional settings are the parameters dictating the noisiness of the synthetic feedback. The synthetic feedback is generated using the following formulas:
$$ 
\begin{align}
 \textrm{synthetic preference} &= \begin{cases}
    a_{1} \succ a_{2}  && w.p. \quad g\left(\frac{f(a_1)-f(a_2)}{\tilde{c}_p}\right) \\
    a_{2} \succ a_{1}  && w.p. \quad 1 - g\left(\frac{f(a_1)-f(a_2)}{\tilde{c}_p}\right),
    \end{cases}  \\
     \textrm{synthetic suggestion} &= \begin{cases}
    \bar{a} \succ a  && w.p. \quad g\left(\frac{f(\bar{a})-f(a)}{\tilde{c}_c}\right) \\
    a \succ \bar{a}  && w.p. \quad 1 - g\left(\frac{f(\bar{a})-f(a)}{\tilde{c}_c}\right),
    \end{cases} \\
    \textrm{synthetic ordinal label} &= \begin{cases}
    o_m = r_m  && w.p. \quad g\left( \frac{\tilde{b}_{r_m} - f(a_m)}{\tilde{c}_o} \right) - g \left( \frac{\tilde{b}_{r_m-1} - f(a_m)}{\tilde{c}_o}\right),
    \end{cases} 
\end{align}
$$

where $$f$$ is the provided "true" utility function, $$\tilde{c}_p$$ is defined as `settings.simulation.simulated_pref_noise`, $$\tilde{c}_c$$ is defined as `settings.simulation.simulated_coac_noise` and $$\tilde{c}_o$$ is defined as `settings.simulation.simulated_ord_noise`. 

POLAR instanteates the learning algorithm based on a structure of settings. These settings can include many things, but are required to include: a definition of the action space, the selected learning objectives, the types of feedback to include, and the learning hyperparameters. 

### Number of ordinal categories: `settings.feedback.num_ord_categories`
If you are utilitizing ordinal labels as a feedback mechanism, you will need to specify the number of ordinal categories to include. For example, if you would like to include the categories "bad", "ok", and "good", you will set `settings.feedback.num_ord_categories = 3`, where a label of 1 will correspond to "bad", a label of 2 will correspond to "ok", and a label of 3 will correspond to "good".

### Region of Avoidance (ROA) settings: `settings.roa.use_roa; settings.roa.ord_label_to_avoid; settings.roa.lambda`
If you are utilizing active learning as the acquisition method, then you have an option to avoid a "Region of Avoidance" (ROA) and instead only learn the underlying utility function over the complement: the region of interest (ROI). The choice to use this feature is selected by setting `settings.roa.use_roa = 1`, otherwise POLAR defaults to `settings.roa.use_roa = 0`. The ordinal categories to avoid are then selected by setting `settings.roa.ord_label_to_avoid` to the highest category you'd like to avoid. For example, if you would like to avoid the "bad" and "ok" categories, you would set `settings.roa.ord_label_to_avoid = 2`. Alternatively, if you would only like to avoid the "bad" category, you would set `settings.roa.ord_label_to_avoid = 1`. Lastly, the algorithm defines the actions within the ROI as the actions that satisfy $$ \mf(a) + \lambda \Sigma(a) > b_{\text{ROI}} $$ where $$ \mathcal{N}(\mu,\Sigma)$$ is the posterior distribution, and $$b_{\text{ROI}}$$ is an arbitrary utility threshold separating the ROA from the ROI (POLAR automatically sets $$b_{\text{ROI}}$$). Thus, $$\lambda$$ is a parameter that influences the conservativeness of the ROA. This parameter is set as `settings.roa.lambda`. 

### Defining an Action Space
POLAR requires that action spaces be defined by preset bounds and discretizations for each dimension of the action space. For example, the construction of an action space for a gait library parameterized by step length and step duration bounded by 10-21 centimeters and 0.8-1.2 seconds respectively is as follows:

```
settings.parameters(1).name = 'step length';
settings.parameters(1).lower = 10;
settings.parameters(1).upper = 21;

settings.parameters(2).name = 'step duration';
settings.parameters(2).lower = 0.8;
settings.parameters(2).upper = 1.2;
```

Next, discretizations are determined for each parameter. We suggest selecting your descretizations based on the smallest distinguishable actions for the human user. For example, a human user may not be able to distinguish between step sizes of 10 centimeters and 10.5 centimeters. Instead, they are more likely to be able to distinguish between 10 centimeters and 11 centimeters. For the purposes of this tutorial, we will set the discretizations to the following:
```
settings.parameters(1).discretization = 1;
settings.parameters(2).discretiztaion = 0.1;
```

### Defining the Learning Hyperparameters
For more information on how to tune the hyperparameters visit the [Tuning Hyperparameters]({{site.baseurl}}/hyperparameters/) page. The required hyperparameters are the following:

- Gaussian signal variance: ```settings.gp_settings.signal_variance```
- Posterior noise for preference feedback: ```settings.gp_settings.post_pref_noise```
- Posterior noise for coactive feedback ```settings.gp_settings.post_coac_noise```
- Posterior noise for ordinal feedback ```settings.gp_settings.post_ord_noise```
- GP model noise: ```settings.GP_noise_var```
- Lengthscales for each action space dimension: ```settings.parameters(i).lengthscale``` (for i = 1, ..., number of dimensions)

### Instanteating POLAR using settings
Once all of the user defined settings are constructed as the structure `settings`, the POLAR framework is insteanteated by running:
``
alg = PBL(settings)
``
where "alg" is just the name we use for our object but can be changed to anything.

## Run a Simulation
To run a simulation, the true objectives corresponding to each action must be predefined. The algorithm then uses these true underlying utilities to generate synthetic feedback as explained in [Simulation settings](#simulation-settings). These underlying true utilities are given to the algorithm in `settings.simulation.true_objectives` and must correspond to the discretized actions of the entire action space listed in `alg.settings.points_to_sample`. The maximum utility is then defined as `settings.simulation.true_bestObjective`, with the action obtaining this best utility defined as `settings.simulation.true_best_action` and the global index of this action being `settings.simulation.true_best_action_globalind`. These last three properties are just included for ease of plotting later on. If you are using ordinal labels, the true ordinal labels are also defined as `settings.simulation.true_ordinal_labels`.

A simulation is run using:
``
alg.runSimulation(plottingFlag,isSave);
``
where `plottingFlag` is a flag indicating if you would like plots to be simulated in real time as the simulation is executed, and `isSave` is a flag indicating if you would like the results of the simulation to be saved in the [save folder](#save-folder-settingssave_folder).

Plots of the simulation can be plotted using the following commands:
``
plotting.plotMetrics(alg)
plotting.plotPosterior(alg)
``
where plotMetrics plots four subplots of different learning objective metrics, plotFrequency plots the number of actions sampled in each of the discretized action bins, and plotPosterior plots the final learned posterior where again isSave is a flag indicating if the plot should be saved, and iter indicates the iteration at which you'd like the posterior to be plotted. If this second input is not included, the posterior is animated across all iterations.

## Run an Experiment
To start a new experiment, run the following command
``
alg.runExperiment(plottingFlag,isSave,export_folder);
``
where plottingFlag and isSave are again plotting and saving flags, and export_folder is the directory location to which yaml files of the actions to sample will be saved. If export_folder is not included, then yaml files will not be produced.