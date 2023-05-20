# Sample Exam Questions
*Advanced Macroeconometrics, Summer Term 2023*

---

#### What is meant by Bayesian ‘updating’?

In the Bayesian framework, we start with existing **prior** beliefs that we subsequently **update** using observed data to obtain **posterior** beliefs. Formally, we update our prior belief about a latent (unobserved) value $\theta$ using the unobserved data $\mathcal{D}$ to get an updated belief:

$$
  p(\theta) \times p(\mathcal{D}\mid\theta) \rightarrow p(\theta\mid\mathcal{D}).
$$

For this, we use Bayes's Rule:

$$
P(A\mid B) = \frac{P(B\mid A)P(A)}{P(B)} \propto P(B\mid A)P(A).
$$

For our prior, we can use historical data, theoretical insights or external information. Alternatively, we can use an uninformative prior. Using probability distributions instead of point values, we get Bayes's Theorem:

$$
p(\theta \mid \mathcal{D}) \propto p(\mathcal{D}\mid\theta)p(\theta).
$$

---

#### How can we interpret $p$, the main parameter of the Bernoulli distribution: $f(x\mid p) = p^x\cdot (1-p)^{(1-x)}$?

$p$ can be interpreted as the probability of success of a Bernoulli trial. It is also the expected value of a Bernoulli distribution.

##### Come up with a conjugate prior for a Bernoulli likelihood and derive the posterior distribution.

A conjugate proir for the Bernoulli Distrubution is a Beta prior. If the Prior is distrubiuted Beta(a0, b0), then the Posterior will be distributed: Beta(a0 + Sn, b0 + n - Sn), where Sn is the number of successes and n-Sn is the number of fails. 

---

#### Describe the Poisson distribution and propose suitable priors (concrete examples for them and properties that would be desirable) for its parameter $\mu$.

The Poisson distribution is a discrete probability distribution that can be used to describe the number of occurrences of an event in a given interval (e.g. of time). It has one parameter, $\lambda$, which is equal to its expected value and its variance. Its probability mass function (PMF) is given by

$$
  f(k, \lambda) = \mathrm{Pr}(X = k) = \frac{\lambda^ke^{-\lambda}}{k!}.
$$

We assume that the occurrence of an event does not affect the probability of the next event occurring, i.e. that events are independent.

---

#### Consider the classical linear model; what parameters are there to model?

Sophia: In the classical linear model, the ordinary least squares model, there are several parameters to model. In case of a simple linear regression model with one dependent variable and one independent variable. The model can be represented as:

Y = β₀ + β₁X + ε,

Here Y is the dependent variable, X is the independent variable, β₀ is the intercept parameter, β₁ is the slope parameter
ε is the error term, assumed to be normally distributed with mean zero and constant variance σ².

##### What is the sampling distribution of this model and how is it related to conjugate parameters for the priors?

Sophia: The sampling distribution of the classical linear model assumes that the error term ε follows a normal distribution with mean zero and constant variance σ². Therefore, the dependent variable Y is also normally distributed with mean β₀ + β₁X and variance σ². Conjugate priors are prior distributions that, when combined with the likelihood function, lead to posterior distributions that have the same functional form as the priors.

##### Show how to use the dependent Normal Inverse-Gamma prior to derive posterior moments for this model.

---

#### What does it mean for a Markov chain Monte Carlo sampler to have ‘converged’?

Sophia: In the context of Markov chain Monte Carlo (MCMC) sampling, "convergence" refers to the property of the sampler reaching a stable state where it effectively explores the target distribution and provides reliable estimates of the parameters of interest. When an MCMC sampler has converged, it implies that the samples produced by the chain are approximately drawn from the desired posterior distribution. We called this the stationary distribution. 

##### How can we assess the convergence of an MCMC sampler?

Sophia: Assessing the convergence of an MCMC sampler is crucial to ensure the validity and reliability of the results. There are several diagnostic methods to assess convergence: 
- From the Slides(16/28 in estimation): We use convergence checks(plots and statistics), and multiple chains (with different starting values) to assess convergence. 
- Visual inspection: Traceplots and density plots of the MCMC samples can be visually examined to identify any patterns or trends. Convergence is indicated when the chains appear stable, with no significant drift or systematic patterns over iterations.
- Visual inspection: QQ plots are scatterplots created by plotting two sets of qualtiles against one another. If both sets of quantiles come from the same distribution, we should see the points forming a straight line. 
- multiple chains: Slide 22 until the end of the chapter (estimation). But I did non really understand them haha. 
- From Slides: Discard the first S0 draws as burn-in, such that the sampler has converged to its stationary distribution. 
- The choice of the starting value is deterministic, but irrelevant if we obtain enough samples. 

##### Draw two traceplots for a Markov chain that (1) has likely converged, and (2) that has not. Suppose you want to estimate a model with this MCMC simulation — what are the implications of (non-)convergence?
Sophia: Convergence: If the MCMC sampler has converged, the estimates derived from the samples are reliable and can be considered representative of the posterior distribution. In this case, the parameter estimates, their uncertainties, and any derived quantities can be trusted for further analysis and inference.
Sophia: Non-convergence: If the MCMC sampler has not converged, the estimates derived from the samples may be biased or unreliable. Non-convergence can lead to incorrect inference, misleading parameter estimates, and underestimated uncertainties. In such cases, it is essential to identify the cause of non-convergence and take appropriate steps to address the issue, such as running the sampler for a longer burn-in period, adjusting sampler parameters, or using different initialization values.

---

#### You want to prepare for an exam on Bayesian econometrics and take a preparatory test five times in a row. Explain why your later results may not be a good predictor for your performance in general.

---

#### You want to assess (and incentivize) the knowledge, performance, and progress of students in your class. What are potential benefits of using three different criteria for grading?

---

#### You want to learn about the effect of drinking between 100ml–1000ml of Club Mate per lecture on your percentage points in a given course. Specify a model; propose two different priors (incl. parameters) for the effect (one should convey your prior, the other should serve as sensitivity check).

Sophia: To study the effect of drinking between 100ml-1000ml of Club Mate per lecture on your percentage points in a given course, we can specify a linear regression model. The dependent variable is "Percentage Points" and the independent variable is "Club Mate."

The linear regression model looks like: 

Percentage Points = β₀ + β₁ * Club Mate + ε

Where: Percentage Points: The percentage points achieved in the course. Club Mate: The amount of Club Mate consumed per lecture (measured in ml).
β₀: The intercept, representing the expected percentage points when no Club Mate is consumed.
β₁: The slope coefficient, representing the expected change in percentage points for each additional ml of Club Mate consumed.
ε: The error term, assuming a normal distribution with mean zero and constant variance.
Now, let's propose two different priors for the effect (β₁) of Club Mate:

Prior 1 (Conveying Prior):
For the first prior, we can express our prior belief about the effect of Club Mate on percentage points. Let's assume a weak prior belief that Club Mate has a positive effect on performance. We can choose a normal prior distribution with mean 0.02 and standard deviation 0.01 for β₁. This prior conveys that, on average, we expect a 0.02 increase in percentage points for every additional ml of Club Mate consumed.
β₁ ~ Normal(0.02, 0.01)

Prior 2 (Sensitivity Check):
For the second prior, we can choose a more diffuse prior that allows for a wider range of possible effects. This prior serves as a sensitivity check to explore different scenarios. We can select a Cauchy prior distribution with a location parameter of 0 and a scale parameter of 0.1 for β₁. The Cauchy distribution has heavier tails compared to the normal distribution, allowing for the possibility of extreme effects.
β₁ ~ Cauchy(0, 0.1)

By using these two different priors, we can explore different assumptions and assess the sensitivity of the results to different prior specifications. The first prior conveys our initial belief about the effect, while the second prior allows for a more flexible range of possible effects, accounting for greater uncertainty or alternative hypotheses.

---

#### The Normal distribution approximately arises in many situations, due to the central limited theorem. What are the assumptions behind the theorem?

Sophia: The central limit theorem (CLT) is a fundamental result in probability theory that provides conditions under which the sum or average of a large number of independent and identically distributed random variables approximates a normal distribution, regardless of the distribution of the individual variables. The assumptions behind the CLT are as follows:

Independence: The random variables should be independent of each other. This means that the outcome of one variable does not affect the outcome of any other variable.
Identical Distribution: The random variables should have the same probability distribution. Although they may have different parameter values (such as mean or variance), the underlying distribution remains the same.
Finite Variance: The random variables should have a finite variance. This assumption ensures that the variability of the individual variables is not too extreme.

##### Random variables in many practical settings do not display the limited tail behavior of the Normal distribution. Why could that be the case and how could you address this when constructing models for such situations? 

Reasons: 
Heavy-Tailed Distributions: Some real-world phenomena, such as income distribution or stock market returns, exhibit heavy tails, meaning that extreme values occur more frequently than would be expected under a normal distribution.
Skewed Distributions: Many real-world data sets are skewed, with a longer tail on one side. These distributions do not match the symmetric bell shape of the normal distribution.
Bounded Data: In certain situations, the data is constrained within specific bounds, such as proportions or counts, which may violate the assumption of unboundedness required by the normal distribution.

Adress this problem: 
Non-Normal Distributions: Instead of assuming a normal distribution, one can choose a more suitable distribution that better reflects the characteristics of the data. Examples include the log-normal distribution for positively skewed data or the Student's t-distribution for heavy-tailed data.
Transformations: Transforming the data using mathematical functions can help make the data more amenable to a normal distribution. Common transformations include logarithmic, square root, etc. 

---

#### You want to investigate the causal effect of your education on your income (or happiness). You identify a set of 80 variables that may be relevant. Explain why you cannot just use a Bayesian model averaging approach to estimate this causal effect.

Sophia: BMA works well when the number of candidate models is relatively small. With 80 variables, the number of potential models explodes exponentially, making it challenging to evaluate all possible combinations of variables. The computational burden increases exponentially as the number of variables and models grow, thus BMA seems impractical in this context.

Also: Like the Bayes Information Criterion (BIC), BMA measures how well the model fits the past but not how well the model predicts the future.

---

#### Why and in which settings can the BIC be used as an approximation to the marginal likelihood?

Sophia: (Slide 18, Chapter: Priors) The margianal likelihood and the BIC are closely related if the number of observations is large. 
I found a more detailed explanaition in the Intenet: The Bayesian Information Criterion (BIC) is a model selection criterion that balances the goodness of fit of a model with its complexity. While BIC is primarily used for model selection, it can also serve as an approximation to the marginal likelihood in certain settings. 
Reasons: 
1. BIC is derived based on asymptotic properties and the assumption of large sample sizes. Under certain regularity conditions, as the sample size increases, BIC consistently estimates the true model among the candidate models. This consistency property suggests that BIC tends to favor the true model, which is a desirable property of the marginal likelihood.
2. BIC incorporates a penalty term for model complexity based on the number of parameters in the model. This penalty discourages overly complex models that may overfit the data. By penalizing complexity, BIC accounts for a principle,that simpler models are preferred when they provide comparable fit to the data. The penalty term in BIC indirectly accounts for the volume of the parameter space and contributes to approximating the marginal likelihood.

---

#### Give an intutition for why and how you should use weakly informative priors (i.e. shrinkage priors).

##### What is an improper prior — what issues may arise if the posterior is also improper?

An improper prior refers to a prior distribution that does not integrate to a finite value (Not a valid pobability distribuion). Improper priors are often used in Bayesian analysis for convenience or mathematical simplicity. However, using an improper prior can lead to issues when the posterior distribution is also improper.

If the posterior distribution is improper, it means that it does not integrate to a finite value. The main issue with an improper posterior is that it cannot be directly interpreted as a valid probability distribution. In such cases, the posterior cannot be used for making probabilistic statements or performing standard Bayesian inference.

---

#### Explain the difference between dependent and independent sampling.

---

#### Give an intuition for the Minnesota prior setup. State how the prior mean is defined and briefly explain why.

Sophia: The Minessota prior incorporates the idea of shrinkage, which is a way to regularize or shrik the coefficient estimates to zero. It adresses the issue of overfitting and instability that can arise when estimating the VAR models with a large number of varaibles (curse of dimensionality). The key idea behind the Missesota prior is to impose a hierarchical structure on the coefficients of the VAR model. Insted of assuming a common prior for all the coefficients, the Minnesota prior allows for different amounts of shirinkage for each coefficient based on its lag order and the variable it corresponds to. 

The Prior mean ist defined by E[A] = (I, 0, ... , 0). The mean is zero exept for the elements corresponding to the fist own lag of the dependent varaible in each equation. This induces a higher consistency and pushes the system towards random walk behavior. 

---

#### Write down a $\mathrm{VAR}(p)$ model in reduced form. Explain what is meant by the curse of dimensionality.

Sophia: 
yt = c + A1$\mathrm{y}(t-1)$ + ... + Ap$\mathrm{y}(t-p)$ + et, with c denoting a constant. 
Curse of dimensionality: If there are M equiations, one for each M variables and p lags of each of the varaibles in each euation, M + pM^2 parameters have to be estimated. 

---

#### You watched the following Youtube video and want to evaluate the monetary policy of J-Pow. You estimate a vector autoregression with the federal funds rate and other relevant variables, and obtain impulse response functions. How can you interpret these IRFs?

<div align="center">
  <a href="https://www.youtube.com/watch?v=GI7sBsBHdCk"><img src="https://img.youtube.com/vi/GI7sBsBHdCk/0.jpg" alt="Youtube Video"></a>
</div>

---
