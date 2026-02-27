
# Kalman Filter function by Bruno Tebaldi ---------------------------------
# Adapted from Ricardo Masini
# Model terminology from Hamilton, J.D. (1994)

# model = list(L = matrix(1, nrow = r, ncol = r),
#              A = matrix(1, nrow = k, ncol = n),
#              H = matrix(1, nrow = r, ncol = n),
#              Q = matrix(1, nrow = r, ncol = r),
#              R = matrix(c(1,0,0,0,1,0,0,0,1), nrow = n, ncol = n)  )

KalmanFilter = function(Obs, Exo, Model, xi_0 = NULL, P_0 = NULL) {
  # Model=model
  # Data as matrix (pxT)
  # Model has 4 matrices H(pxm), F(mxm), R(pxp) and Q(mxm)
  
  # Hamilton, J.D. (1994) - Time Series Analysis
  
  # Model
  # (1) xi_{t+1} = L xi_{t} + v_{t+1} 
  # (2) y_{t} = A' x_{t} + H' xi_{t} + w_{t}
  
  # (1) is the state equation
  # (2) is the observation equation
  # v_{t} and w_{t} are white noise vectors.
  
  # Dimensions
  # xi_{t}: r x 1
  # L     : r x r
  # v_{t} : r x 1
  # 
  # y_{t} : n x 1
  # A'    : n x k
  # x_{t} : k x 1
  # H'    : n x r
  # w_{t} : n x 1 
  # 
  # E[v_{t} v_{tau}'] = Q (for t=tau) or 0 (for t!=tau)
  # E[w_{t} w_{tau}'] = R (for t=tau) or 0 (for t!=tau)
  
  
  if(!is.matrix(Obs)){stop("Obs must be a matrix")}
  # browser()
  
  # Inicialização
  r <- dim(model$H)[1]  # Number of state variables
  n <- dim(Obs)[2]      # Number of observation variables
  Time <- dim(Obs)[1]   # Number of time periods
  # Validade if Exogenous variables are informed
  if(is.null(Exo)){
    Exo <- matrix(0, nrow = Time, ncol = 1)
  } 
  k <- dim(Exo)[2]     # Number of exogenous variables
  
  
  # Model consistency check
  error_msg = ""
  if( dim(Model$L)[1] != r ) { error_msg <- sprintf("%s\nmatrix L - Invalid rows - L must be of dimension %dx%d.", error_msg, r, r) }
  if( dim(Model$L)[2] != r ) { error_msg <- sprintf("%s\nmatrix L - Invalid cols - L must be of dimension %dx%d.", error_msg, r, r) }
  
  if( dim(Model$A)[1] != k ) { error_msg <- sprintf("%s\nmatrix A - Invalid rows - A must be of dimension %dx%d.", error_msg, k, n) }
  if( dim(Model$A)[2] != n ) { error_msg <- sprintf("%s\nmatrix A - Invalid cols - A must be of dimension %dx%d.", error_msg, k, n) }
  
  # if( dim(Model$H)[1] != r ) { error_msg <- sprintf("%s\nmatrix H - Invalid rows - H must be of dimension %dx%d.", error_msg, r, n) }
  if( dim(Model$H)[2] != n ) { error_msg <- sprintf("%s\nmatrix H - Invalid cols - H must be of dimension %dx%d.", error_msg, r, n) }
  
  if( dim(Model$Q)[1] != r ) { error_msg <- sprintf("%s\nmatrix Q - Invalid rows - Q must be of dimension %dx%d.", error_msg, r, r) }
  if( dim(Model$Q)[2] != r ) { error_msg <- sprintf("%s\nmatrix Q - Invalid cols - Q must be of dimension %dx%d.", error_msg, r, r) }
  
  if( dim(Model$R)[1] != n ) { error_msg <- sprintf("%s\nmatrix R - Invalid rows - R must be of dimension %dx%d.", error_msg, n, n) }
  if( dim(Model$R)[2] != n ) { error_msg <- sprintf("%s\nmatrix R - Invalid cols - R must be of dimension %dx%d.", error_msg, n, n) }
  
  if( dim(Model$R)[2] != n ) { error_msg <- sprintf("%s\nmatrix R - Invalid cols - R must be of dimension %dx%d.", error_msg, n, n) }
  if( dim(Model$R)[2] != n ) { error_msg <- sprintf("%s\nmatrix R - Invalid cols - R must be of dimension %dx%d.", error_msg, n, n) }
  
  if( dim(Exo)[1] != Time ) { error_msg <- sprintf("%s\nExogenous variables have invalid time index - Expected %d periods.", error_msg, n, n) }
  
  if(nchar(error_msg) > 0){stop(error_msg)}
  
  # Cosntroi as matrizes de resposta
  # P   : P_{t|t-1}        (r x r)
  # P_  : P_{t+1|t}        (r x r)
  # xi  : xi_{t|t-1}       (r x 1)
  # xi_ : xi_{t+1|t}       (r x 1)
  # y   : y_{t}            (n x 1)
  # y_  : y_{t+1|t}        (n x 1)
  # x   : x_{t}            (k x 1)
  # x_  : x_{t+1}          (k x 1)  
  
  hats <- list("P" = matrix(NA, nrow = Time+1, ncol = r^2),
               "xi" = matrix(NA, nrow = Time+1, ncol = r),
               "y" = matrix(NA, nrow = Time+1, ncol = n),
               "MSE" = matrix(NA, nrow = Time+1, ncol = n^2),
               "KalmanGain" = matrix(NA, nrow = Time+1, ncol = r*n))
  
  
  # Model
  # (1) xi_{t+1} = L xi_{t} + v_{t+1} 
  # (2) y_{t} = A' x_{t} + H' xi_{t} + w_{t}
  
  
  # Unconditional mean of the State variables
  if(is.null(xi_0)) {
    hats$xi[1, ] <- rep(0 , r)
  } else {
    hats$xi[1,] <- as.vector(xi_0)
  }
  
  
  if(is.null(P_0)) {
    hats$P[1,] <- rep(0 , r^2)
  } else {
    hats$P[1,] <- as.vector(P_0)
  }
  
  # P   : P_{t|t-1}        (r x r)
  # P_  : P_{t+1|t}        (r x r)
  # xi  : xi_{t|t-1}       (r x 1)
  # xi_ : xi_{t+1|t}       (r x 1)
  # y   : y_{t}            (n x 1)
  # y_  : y_{t+1|t}        (n x 1)
  # x   : x_{t}            (k x 1)
  # x_  : x_{t+1}          (k x 1)
  
  # Get P, xi, y, x
  for (i in 1:Time) {
    
    xi <- t(hats$xi[i, ,drop=FALSE])
    # P <- matrix(rep(0 , r^2), nrow = r, ncol = r)
    P <- matrix(hats$P[i, ,drop=TRUE], nrow = r, ncol = r)
    y <- t(Obs[i, , drop=FALSE])
    x <- t(Exo[i, , drop=FALSE])
    if(i == Time){
      x_ <- 0
    } else {
      x_ <- t(Exo[i+1, , drop=FALSE])
    }
    

    # Kalman gain - Hamilton (1994) : 13.2.19
    K <- model$L %*% P %*% model$H %*% solve(t(model$H) %*% P %*% model$H + model$R)
    
    # Prediction of State - Hamilton (1994) : 13.2.23
    K_aux <-  K %*% (y - t(model$A) %*% x - t(model$H) %*% xi)
    K_aux[is.na(K_aux)] <- 0
    xi_ <- model$L %*% xi + K_aux
    
    # Prediction of Obs - Hamilton (1994) : 13.2.24
    y_ <- t(model$A) %*% x_ + t(model$H) %*% xi_ 
    
    # Prediction of Inference - Hamilton (1994) : 13.2.22
    # P_ <- model$L %*% P %*% t(model$L) - K %*% t(model$H) %*% P %*% t(model$L) + model$Q
    
    # Prediction of Inference - Hamilton (1994) : 13.2.28
    P_ <- (model$L - K %*% t(model$H)) %*% P %*% (t(model$L) - model$H %*% t(K)) + K %*% model$R %*% t(K) + model$Q
    
    # MSE associated with y_ - Hamilton (1994) : 13.2.25
    MSE_ <- t(model$H) %*% P_ %*% model$H + model$R
    
    # Save the results in the matrix vector
    hats$P[i+1,] <- as.vector(P_)
    hats$xi[i+1,] <- as.vector(xi_)
    hats$y[i+1,] <- as.vector(y_)
    hats$MSE[i+1,] <- as.vector(MSE_)
    hats$KalmanGain[i, ] <- as.vector(K)
  }
  
  return(hats)
}
