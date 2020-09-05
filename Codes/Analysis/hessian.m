% fminsearch is suggested for nonsmooth objective functions, it is a simplex-based solver
% fminunc assumes your problem is differentiable
% if function is not differentiable, a genetic algorithm (global search or patternsearch) is required
% fminunc would almost certainly be faster and more reliable than fminsearch
% fminunc returns an estimated Hessian matrix at the solution. 
% If your objective function does not include a gradient, use 'Algorithm' = 'quasi-newton'
% In fminunc, the Hessian is only used by the trust-region algorithm
% The Quasi-Newton Algorithm computes the estimate by finite differences, so the estimate is generally accurate.
% HessUpdate is a method for choosing the search direction in the Quasi-Newton algorithm, 'bfgs' is the default
% fminunc can have trouble with minimizing a simulation or differential equation, in which case you might 
% need to take bigger finite difference steps (set DiffMinChange to 1e-3 or so)

%  Search methods that use only function evaluations (e.g., the simplex search of Nelder and Mead) are 
% most suitable for problems that are not smooth or have a number of discontinuities. 
% Gradient methods are generally more efficient when the function to be minimized is continuous in its 
% first derivative. Higher order methods, such as Newton's method, are only really suitable when the 
% second-order information is readily and easily calculated, because calculation of second-order information, 
% using numerical differentiation, is computationally expensive. Quasi-Newton methods avoid this by 
% using the observed behavior of f(x) and ?f(x) to build up curvature information to make an approximation 
% to H using an appropriate updating technique. The BFGS formula is thought to be the most effective for 
% use in a general purpose method.

% https://www.mathworks.com/matlabcentral/answers/...
% 40375-question-on-optimization-problem-and-fminsearch-fminunc-lsqnonlin

% https://stackoverflow.com/questions/24360774/matlab-fminsearch-hessians

% https://www.mathworks.com/matlabcentral/answers/90374-fminsearch-finds-local-minimum-when-fminunc-does-not

% https://www.mathworks.com/help/optim/ug/hessian.html#bsapedg
% https://www.mathworks.com/help/optim/ug/fminunc.html
% https://www.mathworks.com/help/optim/ug/unconstrained-nonlinear-optimization-algorithms.html#f171