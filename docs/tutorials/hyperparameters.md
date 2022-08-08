---
layout: default
title: Tuning Hyperparameters
permalink: /hyperparameters/
parent: Tutorials
nav_order: 4
---

There are several hyperparameters used in POLAR. Including the following major hyperparameters: 

<details open markdown="block">
  <summary>
    Contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

In this tutorial we discuss methods of tuning these hyperparameters.

## Lengthscales

The following is an example of three different lengthscales for the `1D Function` example in the POLAR toolbox:
<div class="row">
  <div class="column">
    <img src="../assets/images/tuning_lengthscales/small_lengthscale.png" alt="Small Lengthscale" style="width:30%">
    <img src="../assets/images/tuning_lengthscales/medium_lengthscale.png" alt="Medium Lengthscale" style="width:30%">
    <img src="../assets/images/tuning_lengthscales/large_lengthscale.png" alt="Large Lengthscale" style="width:30%">
  </div>
</div>

Within the `1D Function` example folder, there is a script called `how_to_tune_lengthscale.m` that demonstrates the effect of the lengthscale on the learning performance: 
![Learning Performance](../assets/images/tuning_lengthscales/compared_optimalerror.png)

As shown by the figure, too small of a lengthscale results in a slower learning rate, while too large of a lengthscale results in overly-confident assumptions about the underlying optimal action.

## GP Noise Variance

## GP Feedback Noise

## Upper Confidence Bound for Region of Avoidance
This setting is stored in the learning algorithm as ``settings.roa.lambda`` and appears in the equation used to estimate the region of avoidance.