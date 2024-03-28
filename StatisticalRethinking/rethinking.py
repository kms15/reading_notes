"""JAX implementations of the author's `rethinking` R library"""

from functools import partial

import jax
from jax import numpy as jnp
from jax import scipy as jsp
from jax import random as jr
from jax.scipy import optimize
from tensorflow_probability.substrates import jax as tfp
from tensorflow_probability.substrates.jax import distributions as tfd

@jax.jit
def PI(samples, prob):
    n = samples.shape[0]
    sorted_samples = jnp.sort(samples)
    return sorted_samples[jnp.array([(n*(1 - prob)/2), (n*(1 + prob)/2)]).astype(int)]

def HPDI(samples, prob):
    n = samples.shape[0]
    sorted_samples = jnp.sort(samples)
    samples_per_bin = int(prob * n)
    bin_widths = sorted_samples[samples_per_bin:] - sorted_samples[:-samples_per_bin]
    smallest_bin = jnp.argmin(bin_widths)
    return sorted_samples[jnp.array([smallest_bin, smallest_bin + samples_per_bin])]

@partial(jax.jit, static_argnames=['n'])
def kde(samples, adjust=1., n=512):
    m = samples.shape[0]
    sorted_samples = jnp.sort(samples)
    iqr = sorted_samples[3*m//4] - sorted_samples[m//4]
    sd = jnp.std(sorted_samples)
    # Silverman's (1986) rule of thumb:
    bw = adjust*0.9*samples.shape[0]**(1./5)*jnp.minimum(iqr/1.34,sd)
    minx = sorted_samples[0] - 2*bw
    maxx = sorted_samples[-1] + 2*bw
    bins = jnp.linspace(minx, maxx, n+1)
    binned_samples,_ = jnp.histogram(
        sorted_samples,
        bins=bins,
        range=(minx, maxx),
        density=True
    )
    xs = (bins[1:] + bins[:-1])/2
    kernels = tfd.Normal(xs, bw).prob(xs[:,jnp.newaxis])
    ys = jnp.tensordot(binned_samples, kernels, [[0],[1]])
    return xs,ys

def chainmode(samples, *args, **nargs):
    xs,ys = kde(samples, *args, **nargs)
    return xs[jnp.argmax(ys)]

def quap(log_likelihood, guess):
    def safe_neg_log_likelihood(beta):
        l = log_likelihood(beta)
        return jnp.where(jnp.isfinite(l), -l, 1000+jnp.abs(beta).sum())
    return jspopt.minimize(
        safe_neg_log_likelihood, 
        jnp.asarray(guess),
        method="BFGS"
    )