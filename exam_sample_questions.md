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

##### What is the sampling distribution of this model and how is it related to conjugate parameters for the priors?

##### Show how to use the dependent Normal Inverse-Gamma prior to derive posterior moments for this model.

---

#### What does it mean for a Markov chain Monte Carlo sampler to have ‘converged’?

##### How can we assess the convergence of an MCMC sampler?

##### Draw two traceplots for a Markov chain that (1) has likely converged, and (2) that has not. Suppose you want to estimate a model with this MCMC simulation — what are the implications of (non-)convergence?

---

#### You want to prepare for an exam on Bayesian econometrics and take a preparatory test five times in a row. Explain why your later results may not be a good predictor for your performance in general.

---

#### You want to assess (and incentivize) the knowledge, performance, and progress of students in your class. What are potential benefits of using three different criteria for grading?

---

#### You want to learn about the effect of drinking between 100ml–1000ml of Club Mate per lecture on your percentage points in a given course. Specify a model; propose two different priors (incl. parameters) for the effect (one should convey your prior, the other should serve as sensitivity check).

---

#### The Normal distribution approximately arises in many situations, due to the central limited theorem. What are the assumptions behind the theorem?

##### Random variables in many practical settings do not display the limited tail behavior of the Normal distribution. Why could that be the case and how could you address this when constructing models for such situations?

---

#### You want to investigate the causal effect of your education on your income (or happiness). You identify a set of 80 variables that may be relevant. Explain why you cannot just use a Bayesian model averaging approach to estimate this causal effect.

---

#### Why and in which settings can the BIC be used as an approximation to the marginal likelihood?

---

#### Give an intutition for why and how you should use weakly informative priors (i.e. shrinkage priors).

##### What is an improper prior — what issues may arise if the posterior is also improper?

---

#### Explain the difference between dependent and independent sampling.

---

#### Give an intuition for the Minnesota prior setup. State how the prior mean is defined and briefly explain why.

---

#### Write down a $\mathrm{VAR}(p)$ model in reduced form. Explain what is meant by the curse of dimensionality.

---

#### You watched <https://www.youtube.com/watch?v=GI7sBsBHdCk&pp=ygURaSBuZWVkIGEgaGVybyBmZWQ%3D> and want to evaluate the monetary policy of J-Pow. You estimate a vector autoregression with the federal funds rate and other relevant variables, and obtain impulse response functions. How can you interpret these IRFs?


[![Youtube Video][(https://img.youtube.com/vi/GI7sBsBHdCk/0.jpg)](https://www.youtube.com/watch?v=GI7sBsBHdCk)

---
