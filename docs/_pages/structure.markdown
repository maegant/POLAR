---
layout: page
title: Toolbox Structure
permalink: /structure/
mathjax: true
---

The POLAR toolbox consists of the following classes:
- PBL
- Sampling
- User Feedback
- Synthetic Feedback
- [GP]({{site.baseurl}}//structure/#gp)
- EvaluatePBL
- Compare
- Validation

To view the documentation for any of these classes class, you can use the 'doc' command in MATLAB.

Additionally, the POLAR toolbox includes several plotting capabilities, most of which are included in the +plotting folder.

## GP
The GP class takes in gp_settings (hyperparameters of the Bayesian inference), pairwise preference data, coactive feedback (modeled as pairwise preferences) data, ordinal label data, and the actions over which to infer the GP. 

Specifically, the GP class computes the maximum a posteriori (MAP) estimate of the Bayesian posterior using the following optimization problem:

$$ r_{\text{MAP}} = \text{argmin}_{r \in \mathbb{R}^{|{A}|}} ~\mathcal{S}(r), $$
with the first derivative terms of $\mathcal{S}(r)$ being:

$$
\begin{aligned}
    \frac{\partial -\ln \mathcal{P}(\bf{a}_{k1} \succ \bf{a}_{k2} \mid r(\bf{a}_{k1}), r(\bf{a}_{k2}))}{\partial r(\bf{a}_i)} &= \frac{-s_k(\bf{a}_i)}{c_p} \frac{\dot{g}(z_k)}{g(z_k)}, \\
    \frac{\partial -\ln \mathcal{P}(\bar{\bf{a}}_l \succ \bf{a}_{l} \mid r(\bar{\bf{a}}_l), r(\bf{a}_{l}))}{\partial r(\bf{a}_i)} &= \frac{-s_l(\bf{a}_i)}{c_c} \frac{\dot{g}(z_l)}{g(z_l)}, \\
    \frac{\partial -\ln \mathcal{P}( (\bf{a}_m,o_m) \mid r(\bf{a}_m))}{\partial r(\bf{a}_i)} &= \frac{1}{c_o} \frac{\dot{g}(z_{m1}) - \dot{g}(z_{m2})}{g(z_{m1}) - g(z_{m2})},
\end{aligned}
$$

and the second derivative terms: 
$$
\begin{aligned}
    \frac{\partial^2 -\ln \mathcal{P}(\bf{a}_{k1} \succ \bf{a}_{k2} \mid r(\bf{a}_{k1}), r(\bf{a}_{k2}))}{\partial r(\bf{a}_i)r(\bf{a}_j)} &= \frac{s_k(\bf{a}_i)s_k(\bf{a}_j)}{c_p^2}  \left( \frac{\dot{g}(z_k)^2}{g(z_k)^2} - \frac{\ddot{g}(z_k)}{g(z_k)} \right), \\
    \frac{\partial^2 -\ln \mathcal{P}(\bar{\bf{a}}_l \succ \bf{a}_{l} \mid r(\bar{\bf{a}}_l), r(\bf{a}_{l}))}{\partial r(\bf{a}_i)r(\bf{a}_j)} &= \frac{s_l(\bf{a}_i)s_l(\bf{a}_j)}{c_c^2} \left( \frac{\dot{g}(z_l)^2}{g(z_l)^2} - \frac{\ddot{g}(z_l)}{g(z_l)} \right), \\
    \frac{\partial^2 -\ln \mathcal{P}( (\bf{a}_m,o_m) \mid r(\bf{a}_m))}{\partial r(\bf{a}_i)r(\bf{a}_j)} &= \frac{1}{c_o^2} \Bigg( \bigg( \frac{\dot{g}(z_{m1}) - \dot{g}(z_{m2})}{g(z_{m1}) - g(z_{m2})}  \bigg)^2   -  \bigg( \frac{\ddot{g}(z_{m1}) - \ddot{g}(z_{m2})}{g(z_{m1}) - g(z_{m2})}  \bigg) \Bigg),
\end{aligned}
$$

where $g: \mathbb{R} \to (0,1)$ represents any link function with first derivative $\dot{g}(\cdot)$ and second derivative $\ddot{g}(\cdot)$. The link function terms are defined as:

$$
\begin{aligned}
    z_k &= \left(\frac{r({\bf{a}_{k1}}) - r({\bf{a}_{k2}}) }{ c_p } \right), \quad 
    z_l &&= \left(\frac{r({\bar{\bf{a}}_{l}}) - r({\bf{a}_{l}}) }{ c_c } \right), \\
    z_{m1} &= \frac{b_{o_m} - r(\bf{a}_m)}{c_o}, \quad
    z_{m2} &&= \frac{b_{o_m-1} - r(\bf{a}_m)}{c_o}.
\end{aligned}
$$

Lastly, the indicator functions are defined as:

$$
\begin{aligned}
    s_k(\bf{a}) = \begin{cases} +1 & \bf{a} = \bf{a}_{k1} \\ -1 & \bf{a} = \bf{a}_{k2} \\ 0 & \text{otherwise} \end{cases}, \quad 
    s_l(\bf{a}) = \begin{cases} +1 & \bf{a} = \bar{\bf{a}}_l \\ -1 & \bf{a} = \bf{a}_{l} \\ 0 & \text{otherwise} \end{cases}.
\end{aligned}
$$ 
