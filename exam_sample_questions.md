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

/Max

---

#### How can we interpret $p$, the main parameter of the Bernoulli distribution: $f(x\mid p) = p^x\cdot (1-p)^{(1-x)}$?

$p$ can be interpreted as the probability of success of a Bernoulli trial. It is also the expected value of a Bernoulli distribution.

##### Come up with a conjugate prior for a Bernoulli likelihood and derive the posterior distribution.

A conjugate prior for the Bernoulli Distrubution is a Beta prior. If the Prior is distrubiuted $\mathrm{Beta}(a_0, b_0)$, then the Posterior will be distributed: $\mathrm{Beta}(a_0 + S_n, b_0 + n - S_n)$, where $S_n$ is the number of successes and $n-S_n$ is the number of fails. /Sophia

---

#### Describe the Poisson distribution and propose suitable priors (concrete examples for them and properties that would be desirable) for its parameter $\mu$.

The Poisson distribution is a discrete probability distribution that can be used to describe the number of occurrences of an event in a given interval (e.g. of time). It has one parameter, $\mu$, which is equal to its expected value and its variance. Its probability mass function (PMF) is given by

$$
  f(k\mid\mu) = \mathrm{Pr}(X = k) = \frac{\mu^ke^{-\mu}}{k!}.
$$

We assume that the occurrence of an event does not affect the probability of the next event occurring, i.e. that events are independent.

Per [Wikipedia](https://en.wikipedia.org/wiki/Conjugate_prior), a Gamma-distributed prior for the parameter $\mu$ is a conjugate prior. That means that the posterior derived by combining a Gamma-distributed prior for $\mu$ with the likelihood will be Gamma-distributed. As for the parameters of the Gamma-distributed prior, we could assess the suspected properties of the parameter in question, e.g. by using available information, historical data or economic theory, and then choose the parameters of the Gamma distribution accordingly. If we do not have information on this and/or want to feign ignorance, a non-informative (improper) prior can be used by setting $\alpha=1,\beta=0$, which results in a flat (uniform) distribution over positive values of $\mu$. /Max

---

#### Consider the classical linear model; what parameters are there to model?

In the classical linear model, the ordinary least squares model, there are several parameters to model. In case of a simple linear regression model with one dependent variable and one independent variable. The model can be represented as:

$$
\boldsymbol{y} = \boldsymbol{X\beta} + \boldsymbol{\varepsilon},
$$

where $\boldsymbol{y}$ is the dependent variable, $\boldsymbol{x}$ is the independent variable, $\boldsymbol{\beta}$ are coefficients, and $\boldsymbol{\varepsilon}$ is the error that is assumed to be normally distributed with mean zero and constant variance $\sigma^2$. /Sophia

The free parameters that we model in this regression model are the regression coefficients $\boldsymbol{\beta}$ and the error variance $\sigma^2$. /Max

##### What is the sampling distribution of this model and how is it related to conjugate parameters for the priors?

The sampling distribution of the classical linear model assumes that the error term $\boldsymbol{\varepsilon}$ follows a normal distribution with mean zero and constant variance $\sigma^2$. Therefore, the dependent variable $\boldsymbol{y}$ is also normally distributed with mean $\boldsymbol{X\beta}$ and variance $\sigma^2$. Conjugate priors are prior distributions that, when combined with the likelihood function, lead to posterior distributions that have the same functional form as the priors. /Sophia

The conjugate prior for this analysis depends on what we want to model. To perform inference for $\sigma^2$ when knowing $\boldsymbol{\beta}$, we can use a conjugate Inverse Gamma Prior. To perform inference on $\boldsymbol{\beta}$ when we know $\sigma^2$, we can use a conjugate normal prior. To perform inference for both under the assumption that the variance of $\boldsymbol{\beta}$ depends on $\sigma^2$, we can use a conjugate Normal-Inverse-Gamma prior and obtain a Normal-Inverse-Gamma posterior. To perform inference for both under the assumption that they are independent, we can again use a Normal-Inverse-Gamma prior, but this time, there is no conjugate prior, and we do not get a closed form joint posterior (we do, however, get closed-form conditional posteriors). /Max

##### Show how to use the dependent Normal Inverse-Gamma prior to derive posterior moments for this model.

We can obtain a closed form posterior with the following prior:

$$
\beta \mid \sigma^2 \sim \mathcal{N}_k\left(\boldsymbol{\mu}_0, \sigma^2 \boldsymbol{\Sigma}_0\right), \quad \sigma^2 \sim \mathrm{G}^{-1}\left(c_0, d_0\right) .
$$

The joint posterior of $\left(\beta, \sigma^2\right)$ is then

$$
\beta\left|\sigma^2, \boldsymbol{y} \sim \mathcal{N}_k\left(\boldsymbol{\mu}_n, \sigma^2 \boldsymbol{\Sigma}_n\right), \quad \sigma^2\right| \boldsymbol{y} \sim \mathrm{G}^{-1}\left(c_n, d_n\right),
$$

where:

* $\boldsymbol{\mu}_n = \boldsymbol{\Sigma}_n(\boldsymbol{\Sigma}_0^{-1} \boldsymbol{\mu}_0 + \boldsymbol{X}^{\prime} \boldsymbol{y})$,
* $c_n = c_0 + n / 2$,
* $\boldsymbol{\Sigma}_n = (\boldsymbol{\Sigma}_0^{-1} + \boldsymbol{X}^{\prime} \boldsymbol{X})^{-1}$,
* $d_n = d_0 + \boldsymbol{S}_{\varepsilon} / 2$,
* $\boldsymbol{S}_{\varepsilon} = \boldsymbol{y}^{\prime} \boldsymbol{y} + \boldsymbol{\mu}_0^{\prime} \boldsymbol{\Sigma}_0^{-1} \boldsymbol{\mu}_0 - \boldsymbol{\mu}_n^{\prime} \boldsymbol{\Sigma}_n^{-1} \boldsymbol{\mu}_n$.

Since the posterior follows a well-known probability distribution, we can give moments for it as we would for any Normal or Inverse gamma distribution. For example, the mean of the posterior for $\boldsymbol{\beta}$ equals $\boldsymbol{\mu}_n$. /Max

---

#### What does it mean for a Markov chain Monte Carlo sampler to have ‘converged’?

In the context of Markov chain Monte Carlo (MCMC) sampling, "convergence" refers to the property of the sampler reaching a stable state where it effectively explores the target distribution and provides reliable estimates of the parameters of interest. When an MCMC sampler has converged, it implies that the samples produced by the chain are approximately drawn from the desired posterior distribution. We call this the stationary distribution. /Sophia

We have to deterministically choose a starting value for our MCMC sampler. In principle, this can distort inference, as it can influence the stationary distribution and hinder convergence to the joint distribution of $\beta$ and $\sigma^2$ (in the regression context). However, this distortion quickly vanishes as we obtain more and more samples. That is why we can use a burn-in period, a number $S_0$ of first samples that we discard, to address this problem. /Max

##### How can we assess the convergence of an MCMC sampler?

Assessing the convergence of an MCMC sampler is crucial to ensure the validity and reliability of the results. There are several diagnostic methods to assess convergence: 

* From the Slides(16/28 in estimation): We use convergence checks(plots and statistics), and multiple chains (with different starting values) to assess convergence. 
* Visual inspection: Traceplots and density plots of the MCMC samples can be visually examined to identify any patterns or trends. Convergence is indicated when the chains appear stable, with no significant drift or systematic patterns over iterations.
* Visual inspection: QQ plots are scatterplots created by plotting two sets of quantiles against one another. If both sets of quantiles come from the same distribution, we should see the points forming a straight line. 
* Multiple chains: Instead of running a single MCMC chain, multiple chains are independently simulated from different starting points or initial conditions. Each chain is an independent realization of the MCMC algorithm, exploring the parameter space. We could visually inspect the chains. 
* From Slides: Discard the first $S_0$ draws as burn-in, such that the sampler has converged to its stationary distribution. 
* The choice of the starting value is deterministic, but irrelevant if we obtain enough samples. /Sophia

##### Draw two traceplots for a Markov chain that (1) has likely converged, and (2) that has not. Suppose you want to estimate a model with this MCMC simulation — what are the implications of (non-)convergence?

**Convergence:** If the MCMC sampler has converged, the estimates derived from the samples are reliable and can be considered representative of the posterior distribution. In this case, the parameter estimates, their uncertainties, and any derived quantities can be trusted for further analysis and inference.

**Non-convergence:** If the MCMC sampler has not converged, the estimates derived from the samples may be biased or unreliable. Non-convergence can lead to incorrect inference, misleading parameter estimates, and underestimated uncertainties. In such cases, it is essential to identify the cause of non-convergence and take appropriate steps to address the issue, such as running the sampler for a longer burn-in period, adjusting sampler parameters, or using different initialization values. /Sophia

---

#### You want to prepare for an exam on Bayesian econometrics and take a preparatory test five times in a row. Explain why your later results may not be a good predictor for your performance in general.

In Bayesian econometrics, we use the principle of updating our beliefs. Thus, we can use a preparatory test to update our prior beliefs about the outcome of the exam. However, if we complete the same preparatory test five times, we are not able to increase our certainty about the outcome of the exam as we already added the new information after completing the test the first time. /Lucas

---

#### You want to assess (and incentivize) the knowledge, performance, and progress of students in your class. What are potential benefits of using three different criteria for grading?

Let $X$ be the set of econometric skills that a student has. Let that set be partitioned into four subsets $X_E$, the set of skills used in an exam, $X_A$, the set of skills that can be applied to predetermined problem sets, $X_P$, the set of skills used in an independent research project, and all other skills $X_O$. Let $y$ be the knowledge of a student, and let it be a function of the skills in $X$. Assume grading were based only on an exam. Then, assigning a grade $\tilde{y}$ based on a set of predictors in the set $X_E$ only would mean that important explanatory variables would be omitted, and likewise if we used problem sets or a research project only. In using all three criteria, we essentially perform a form of deterministic model averaging between the three seperate assessment criteria models. 

In the course, we talked about Bayesian Model Averaging (BMA), a related concept. There, instead of looking for the "best model" and thereby ignoring uncertainty around the model selection, we consider all candidate models, weighted by their posterior probability. /Max


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

The central limit theorem (CLT) is a fundamental result in probability theory that provides conditions under which the sum or average of a large number of independent and identically distributed random variables approximates a normal distribution, regardless of the distribution of the individual variables. The assumptions behind the CLT are as follows:

* **Independence:** The random variables should be independent of each other. This means that the outcome of one variable does not affect the outcome of any other variable.
* **Identical Distribution:** The random variables should have the same probability distribution. Although they may have different parameter values (such as mean or variance), the underlying distribution remains the same.
* **Finite Variance:** The random variables should have a finite variance. This assumption ensures that the variability of the individual variables is not too extreme. /Sophia

##### Random variables in many practical settings do not display the limited tail behavior of the Normal distribution. Why could that be the case and how could you address this when constructing models for such situations? 

**Reasons: **
* **Heavy-Tailed Distributions:** Some real-world phenomena, such as income distribution or stock market returns, exhibit heavy tails, meaning that extreme values occur more frequently than would be expected under a normal distribution.
* **Skewed Distributions:** Many real-world data sets are skewed, with a longer tail on one side. These distributions do not match the symmetric bell shape of the normal distribution.
* **Bounded Data:** In certain situations, the data is constrained within specific bounds, such as proportions or counts, which may violate the assumption of unboundedness required by the normal distribution.

**Adress this problem: **
* **Non-Normal Distributions:** Instead of assuming a normal distribution, one can choose a more suitable distribution that better reflects the characteristics of the data. Examples include the log-normal distribution for positively skewed data or the Student's t-distribution for heavy-tailed data.
* **Transformations:** Transforming the data using mathematical functions can help make the data more amenable to a normal distribution. Common transformations include logarithmic, square root, etc. /Sophia

---

#### You want to investigate the causal effect of your education on your income (or happiness). You identify a set of 80 variables that may be relevant. Explain why you cannot just use a Bayesian model averaging approach to estimate this causal effect.

BMA works well when the number of candidate models is relatively small. With 80 variables, the number of potential models explodes exponentially, making it challenging to evaluate all possible combinations of variables. The computational burden increases exponentially as the number of variables and models grow, thus BMA seems impractical in this context.

Also, like the Bayes Information Criterion (BIC), BMA measures how well the model fits the past but not how well the model predicts the future. /Sophia

---

#### Why and in which settings can the BIC be used as an approximation to the marginal likelihood?

(Slide 18, Chapter: Priors) The margianal likelihood and the BIC are closely related if the number of observations is large. 

I found a more detailed explanaition in the Intenet: The Bayesian Information Criterion (BIC) is a model selection criterion that balances the goodness of fit of a model with its complexity. While BIC is primarily used for model selection, it can also serve as an approximation to the marginal likelihood in certain settings. 
Reasons: 
* BIC is derived based on asymptotic properties and the assumption of large sample sizes. Under certain regularity conditions, as the sample size increases, BIC consistently estimates the true model among the candidate models. This consistency property suggests that BIC tends to favor the true model, which is a desirable property of the marginal likelihood.
* BIC incorporates a penalty term for model complexity based on the number of parameters in the model. This penalty discourages overly complex models that may overfit the data. By penalizing complexity, BIC accounts for a principle,that simpler models are preferred when they provide comparable fit to the data. The penalty term in BIC indirectly accounts for the volume of the parameter space and contributes to approximating the marginal likelihood. /Sophia

---

#### Give an intutition for why and how you should use weakly informative priors (i.e. shrinkage priors).

Shrinkage priors are often used to counteract the danger of overfitting. In a Bayesian setting, shrinkage priors are used to pull small effects towards zero and thus exclude them from the model, while large effects continue to remain in a model. Especially, when there are more variables than observations, shrinkage priors are necessary to keep the model consistent. To implement this, shrinkage priors are often distributions that have a lot of mass around zero and fat tails. Some examples are the Lasso, Horseshoe, ridge or the Triple-Gamma prior. /Lucas

##### What is an improper prior — what issues may arise if the posterior is also improper?

An improper prior refers to a prior distribution that does not integrate to a finite value (Not a valid pobability distribuion). Improper priors are often used in Bayesian analysis for convenience or mathematical simplicity. However, using an improper prior can lead to issues when the posterior distribution is also improper.

If the posterior distribution is improper, it means that it does not integrate to a finite value. The main issue with an improper posterior is that it cannot be directly interpreted as a valid probability distribution. In such cases, the posterior cannot be used for making probabilistic statements or performing standard Bayesian inference. /?

---

#### Explain the difference between dependent and independent sampling.
Independent sampling refers to data that is given by two random samples which are drawn from two seperate and unrelated populations. One can then compute the desired metric to gain information about differences in the two populations. Example: A community college mathematics department wants to know if an experimental algebra course has higher success rates when compared to a traditional course. The mean grade points for 80 students in the experimental course (treatment) is compared to the mean grade points for 100 students in the traditional course (control).

Dependent sampling refers to data that is drawn from the same population but e.g. at different time points. Thus, each data point in the first sampling has a dependent data point in the second data set. This procedure is also called matched pair sampling and can be used for a one population model of differences. Example: An instructor of a statistics course wants to know if student scores are different on the second midterm compared to the first exam. The first and second midterm scores for 35 students is taken and the mean difference in scores is determined. /Lucas


---

#### Give an intuition for the Minnesota prior setup. State how the prior mean is defined and briefly explain why.

The Minessota prior incorporates the idea of shrinkage, which is a way to regularize or shrik the coefficient estimates to zero. It adresses the issue of overfitting and instability that can arise when estimating the VAR models with a large number of varaibles (curse of dimensionality). The key idea behind the Missesota prior is to impose a hierarchical structure on the coefficients of the VAR model. Insted of assuming a common prior for all the coefficients, the Minnesota prior allows for different amounts of shirinkage for each coefficient based on its lag order and the variable it corresponds to. 

The Prior mean is defined by $\mathrm{E}(\underline{A}) = (\boldsymbol{I},\boldsymbol{0},\dots,\boldsymbol{0})$. The mean is zero exept for the elements corresponding to the fist own lag of the dependent varaible in each equation. This induces a higher consistency and pushes the system towards random walk behavior. /Sophia

---

#### Write down a $\mathrm{VAR}(p)$ model in reduced form. Explain what is meant by the curse of dimensionality.

A reduced form $\mathrm{VAR}(p)$ model is given by:

```math
\boldsymbol{y}_t = \boldsymbol{c} + \boldsymbol{A}_{1} \boldsymbol{y}_{t-1} + \dots + \boldsymbol{A}_p\boldsymbol{y}_{t-p} + \boldsymbol{\varepsilon}_t, \qquad \boldsymbol{\varepsilon}_t \sim \mathcal{N}_M(\boldsymbol{0},\boldsymbol{\Sigma})
```

where $\boldsymbol{c}$ denotes a constant. Using the lag polynomial, we can write it more compactly as:

$$
\boldsymbol{A}(L)\boldsymbol{y}_t = \boldsymbol{c} + \boldsymbol{\varepsilon}_t.
$$

If there are $M$ equiations, one for each of the $M$ variables and $p$ lags of each of the varaibles in each equation, there are $M + pM^2$ parameters in the model. The number of free parameters (elements in $\boldsymbol{c},\boldsymbol{A}_j$ and $\boldsymbol{\Sigma}$) is given by

$$
	M(Mp+1)+\frac{(M+1)M}{2}.
$$

The curse of dimensionality is a term for the difficulty that arises with the number of parameters to estimate if $M$ and $p$ grow. /Sophia, Max

---

#### You watched the following Youtube video and want to evaluate the monetary policy of J-Pow. You estimate a vector autoregression with the federal funds rate and other relevant variables, and obtain impulse response functions. How can you interpret these IRFs?

<div align="center">
  <a href="https://www.youtube.com/watch?v=GI7sBsBHdCk"><img src="https://img.youtube.com/vi/GI7sBsBHdCk/0.jpg" alt="Youtube Video"></a>
</div>

---
