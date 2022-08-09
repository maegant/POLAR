---
layout: default
title: Obtaining User Feedback
permalink: /feedback/
parent: Tutorials
nav_order: 3
mathjax: true
---

There are currently three available feedback mechanisms available in the POLAR toolbox:

## Pairwise Comparisons (Preferences)
When two actions are sampled ($n = 2$), or when two actions are compared ($n = 1$, $b = 1$), then pairwise comparisons are obtained using the question:

>> *Which action do you prefer (0,1,2)*

A user response of 0 indicates "no preference", 1 indicates that $a_1 \succ a_2$, and 2 indicates that $a_2 \succ a_1$.

If more than two actions are being compared, then the pairwise comparisons are obtained using the question:

>> *Give ranking of samples (first index given is most preferred)*

Here, the user provides a ranking of the actions being compared, which is then converted into K choose 2 pairwise preferences (K is the number of actions being compared). For example, if the user provided the ranking $1,3,2$. Then this translates into the pairwise preferences: $a_1 \succ a_3$, $a_1 \succ a_2$, $a_3 \succ a_2$.

## User Suggestions
User suggestions are provided relative to each action space dimension, and with the user feedback of either "larger" or "smaller". These suggestions are obtained through the sequence of questions:


> > *Enter suggestion for sampled action (y or n)*

> > *Enter dimensions to give feedback*

> >*Smaller or Larger?*



## Ordinal Labels
Ordinal labels are provided by asking the user 

> > *Label for Sampled Action $(0:h)$*

Where $h$ is the number of ordinal labels defined in `settings.feedback.num_ord_categories`. A label of 0 indicates "no label".
