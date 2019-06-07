import os,sys
import esig.tosig as ts
import numpy as np


# return_input
def return_input(A,n,m):
    B = np.reshape(A,(int(n),int(m)),order='F')
    print('B is ')
    print(B)
    return B


def siglen(dim,deg,islog):
    
    dim = int(dim)  
    deg = int(deg)
    islog = int(islog)
    if (islog):
        return(ts.logsigdim(dim,deg))
    else:
        return(ts.sigdim(dim,deg))
    end


# run_esig
def run_esig(A,n,m,deg,islog):
    
    m = int(m)  # m is the dimension
    n = int(n)
    islog = int(islog)
    deg = int(deg)
    B = np.reshape(A,(n,m),order='F')
    siglength = siglen(m,deg,islog);
    sigmat = np.zeros((1,siglength)) 
    if islog:
        sigmat[0,:] = ts.stream2logsig(B,deg)
    else:
        sigmat[0,:] = ts.stream2sig(B,deg)
    return(sigmat)
    
