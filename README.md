EBP_Matlab_Code
===============

This is a first version of the Expectation Backpropagation algorithem based on the upcoming NIPS paper:
"Expectation Backpropagation: Parameter-Free Training of Multilayer Neural Networks with Continuous or Discrete Weights"
By D.Soudry, I.Hubara and R.Meir

* Paper Abstract: Multilayer Neural Networks (MNNs) are commonly trained using gradient descent-based methods, such as BackPropagation (BP). Inference in probabilistic graphical models is often done using variational Bayes methods, such as Expectation Propagation (EP). We show how an EP based approach can also be used to train deterministic MNNs. Specifically, we approximate the posterior of the weights given the data using a “mean-field” factorized distribution, in an on-line setting. Using on-line EP and the central limit theorem we find an analytical approximation to the Bayes update of this posterior, as well as the resulting Bayes estimates of the weights and outputs. Despite a different origin, the resulting algorithm, Expectation BackPropagation (EBP), is very similar to BP in form and efficiency. However, it has several additional advantages: (1) Training is parameter-free, given initial conditions (prior) and the MNN architecture. This is useful for large-scale problems, where parameter tuning is a major challenge. (2) The weights can be restricted to have discrete values. This is especially useful for implementing trained MNNs in precision limited hardware chips, thus improving their speed and energy efficiency by several orders of magnitude. We test the EBP algorithm numerically in eight binary text classification tasks. In all tasks, EBP outperforms: (1) standard BP with the optimal constant learning rate  (2) previously reported state of the art. Interestingly, EBP-trained MNNs with binary weights usually perform better than MNNs with continuous (real) weights - if we average the MNN output using the inferred posterior. 

* Some prelimenary results on mnist are availble here:
http://arxiv.org/abs/1503.03562v3

* The Code contains: (1) Real-EPB and Binary-EBP, in the folder "Learning_Algorithms". These two functions are the implementation of algorithms 2 and 1 in the paper's appendix. See documentation inside function for input-outputs.
(2) 8 binary text classification data sets that (as used in the paper), in the folder "Datasets/Classification"

* To Install: (1) Download and extract zip from github (2) Run RunMe.m file (3) Choose algorithm Binary-EBP or Real-EPB
(4) Choose data set according to the given list



