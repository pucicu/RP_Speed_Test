import sys
import numpy as np
from itertools import chain

from scipy.spatial.distance import pdist, squareform

# disable dive by zero warnings
np.seterr(divide="ignore")


def mi(x, maxlag, binrule="fd", pbar_on=True):
    """
    Returns the self mutual information of a time series up to max. lag.
    """
    # initialize variables
    n = len(x)
    lags = np.arange(0, maxlag, dtype="int")
    mi = np.zeros(len(lags))
    # loop over lags and get MI
    
    for i, lag in enumerate(lags):
        # extract lagged data
        y1 = x[:n - lag].copy()
        y2 = x[lag:].copy()
        # use np.histogram to get individual entropies
        H1, be1 = entropy1d(y1, binrule)
        H2, be2 = entropy1d(y2, binrule)
        H12, _, _ = entropy2d(y1, y2, [be1, be2])
        # use the entropies to estimate MI
        mi[i] = H1 + H2 - H12
    
    return lags, mi


def entropy1d(x, binrule):
    """
    Returns the Shannon entropy according to the bin rule specified.
    """
    p, be = np.histogram(x, bins=binrule, density=True)
    r = be[1:] - be[:-1]
    P = p * r
    H = -(P * np.log2(P)).sum()

    return H, be


def entropy2d(x, y, bin_edges):
    """
    Returns the Shannon entropy according to the bin rule specified.
    """
    p, bex, bey = np.histogram2d(x, y, bins=bin_edges, normed=True)
    r = np.outer(bex[1:] - bex[:-1], bey[1:] - bey[:-1])
    P = p * r
    H = np.zeros(P.shape)
    i = ~np.isinf(np.log2(P))
    H[i] = -(P[i] * np.log2(P[i]))
    H = H.sum()

    return H, bex, bey



def fnn(x, tau, maxdim, r=0.10, pbar_on=True):
    """
    Returns the number of false nearest neighbours up to max dimension.
    """
    # initialize params
    sd = x.std()
    r = r * (x.max() - x.min())
    e = sd / r
    fnn = np.zeros(maxdim)
    dims = np.arange(1, maxdim + 1, dtype="int")

    # ensure that (m-1) tau is not greater than N = length(x)
    N = len(x)
    K = (maxdim + 1 - 1) * tau
    if K >= N:
        m_c = N / tau
        i = np.where(dims >= m_c)
        fnn[i] = np.nan
        j = np.where(dims < m_c)
        dims = dims[j]

    # get first values of distances for m = 1
    d_m, k_m = mindist(x, 1, tau)

    # loop over dimensions and get FNN values
    for m in dims:
        # get minimum distances for one dimension higher
        d_m1, k_m1 = mindist(x, m + 1, tau)
        # remove those indices in the m-dimensional calculations which cannot
        # occur in the m+1-dimensional arrays as the m+1-dimensional arrays are
        # smaller
        cond1 = k_m[1] > k_m1[0][-1]
        cond2 = k_m[0] > k_m1[0][-1]
        j = np.where(~(cond1 + cond2))[0]
        k_m_ = (k_m[0][j], k_m[1][j])
        d_k_m, d_k_m1 = d_m[k_m_], d_m1[k_m_]
        n_m1 = d_k_m.shape[0]
        # calculate quantities in Eq. 3.8 of Kantz, Schreiber (2004) 2nd Ed.
        j = d_k_m > 0.
        y = np.zeros(n_m1, dtype="float")
        y[j] = (d_k_m1[j] / d_k_m[j] > e)
        w = (e > d_k_m)
        num = float((y * w).sum())
        den = float(w.sum())
        # assign FNN value depending on whether denominator is zero
        if den != 0.:
            fnn[m - 1] = num / den
        else:
            fnn[m - 1] = np.nan
        # assign higher dimensional values to current one before next iteration
        d_m, k_m = d_m1, k_m1
        
    return  dims,fnn



def embed(x, m, tau):
    """
    Embeds a scalar time series in m dimensions with time delay tau.
    """
    n = len(x)
    k = n - (m - 1) * tau
    z = np.zeros((k, m), dtype="float")
    for i in range(k):
        z[i] = [x[i + j * tau] for j in range(m)]

    return z

def rp(z, e, norm="euclidean", threshold_by="distance"):
    """Returns the recurrence plot of given time series."""
    D = squareform(pdist(z, metric=norm))
    R = np.zeros(D.shape, dtype="int")
    if threshold_by == "distance":
        i = np.where(D <= e)
        R[i] = 1
    elif threshold_by == "fan":
        nk = np.ceil(e * R.shape[0]).astype("int")
        i = (np.arange(R.shape[0]), np.argsort(D, axis=0)[:nk])
        R[i] = 1
    elif threshold_by == "frr":
        e = np.percentile(D, e * 100.)
        i = np.where(D <= e)
        R[i] = 1

    return R


def mindist(x, m, tau):
    """
    Returns the minimum distances for each point in given embedding.
    """
    z = embed(x, m, tau)
    # d = squareform(pdist(z))
    n = len(z)
    d = np.zeros((n, n))
    for i in range(n):
        d[i] = np.max(np.abs(z[i] - z), axis=1)

    np.fill_diagonal(d, 99999999.)
    k = (np.arange(len(d)), np.argmin(d, axis=1))

    return d, k
def normalize(x):
    """
    Returns the Z-score series for x.
    """
    return (x - x.mean()) / x.std()



def det(R, lmin=None, hist=None, verb=True):
    """returns DETERMINISM for given recurrence matrix R."""
    if not lmin:
        lmin = int(0.1 * len(R))
    if not hist:
        if verb: print("estimating line length histogram...")
        nlines, bins, ll = diagonal_lines_hist(R, verb=verb)
    else:
        nlines, bins, ll = hist[0], hist[1], hist[2]
    if verb: print("estimating DET...")
    Pl = nlines.astype('float')
    l = (0.5 * (bins[:-1] + bins[1:])).astype('int')
    idx = l >= lmin
    num = l[idx] * Pl[idx]
    den = l * Pl
    DET = num.sum() / den.sum()
    return DET

def diagonal_lines_hist(R, verb=True):
    """returns the histogram P(l) of diagonal lines of length l."""
    if verb:
        print("diagonal lines histogram...")
    line_lengths = []
    for i in range(1, len(R)):
        d = np.diag(R, k=i)
        ll = _count_num_lines(d)
        line_lengths.append(ll)
    line_lengths = np.array(list(chain.from_iterable(line_lengths)))
    bins = np.arange(0.5, line_lengths.max() + 0.1, 1.)
    num_lines, _ = np.histogram(line_lengths, bins=bins)
    return num_lines, bins, line_lengths

def _count_num_lines(arr):
    """returns a list of line lengths contained in given array."""
    line_lens = []
    counting = False
    l = 0
    for i in range(len(arr)):
        if counting:
            if arr[i] == 0:
                l += 1
                line_lens.append(l)
                l = 0
                counting = False
            elif arr[i] == 1:
                l += 1
                if i == len(arr) - 1:
                    l += 1
                    line_lens.append(l)
        elif not counting:
            if arr[i] == 1:
                counting = True
    return line_lens

def entr(R, lmin=None, hist=None, verb=True):
    """returns ENTROPY for given recurrence matrix R."""
    if not lmin:
        lmin = int(0.1 * len(R))
    if not hist:
        if verb: print("estimating line length histogram...")
        nlines, bins, ll = diagonal_lines_hist(R, verb=verb)
    else:
        nlines, bins, ll = hist[0], hist[1], hist[2]
    if verb: print("estimating ENTR...")
    pl = nlines.astype('float') / float(len(ll))
    l = (0.5 * (bins[:-1] + bins[1:])).astype('int')
    idx1 = l >= lmin
    pl = pl[idx1]
    idx = pl > 0.
    ENTR = (-pl[idx] * np.log(pl[idx])).sum()
    return ENTR


def tau_recurrence(R):
	N=R.shape[0] # R is the Recurrence matrix
	q=np.zeros(N)
	for tau in range(N):
		q[tau]=np.diag(R,k=tau).mean()
	return q


def cpr(Rx, Ry):
    """
    Returns the correlation of probabilities of recurrence (CPR).
    """
    assert Rx.shape == Ry.shape, "RPs are of different sizes!"
    N = Rx.shape[0]
    qx, qy = [np.zeros(N) for i in range(2)]
    for tau in range(N):
        qx[tau] = np.diag(Rx, k=tau).mean()
        qy[tau] = np.diag(Ry, k=tau).mean()

    # obtain indices after taking into account decorrelation time
    e = np.exp(1.)
    try:
        ix = np.where(qx < 1. / e)[0][0]
        iy = np.where(qy < 1. / e)[0][0]
        i = max(ix, iy)
    except IndexError:
        i = N

    # final estimate
    if i < N:
        # normalised data series to mean zero and standard deviation one after
        # removing entries before decorrelation time
        qx_ = qx[i:]
        qx_ = (qx_ - np.nanmean(qx_)) / np.nanstd(qx_)
        qy_ = qy[i:]
        qy_ = (qy_ - np.nanmean(qy_)) / np.nanstd(qy_)

        # estimate CPR as the dot product of normalised series
        C = (qx_ * qy_).mean()
    else:
        C = np.nan

    return C



