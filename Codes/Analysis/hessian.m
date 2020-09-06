% fminsearch uses the Nelder-Mead simplex (direct search) method, it is a simplex-based solver suggested
% for nonsmooth objective functions
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

% the reciprocal condition number is a more accurate measure of singularity than the determinant
% If A is well conditioned, rcond(A) is near 1.0. If A is badly conditioned, rcond(A) is near 0. 
% When A is badly conditioned, a small change in b produces a very large change in the solution to x = A\b. 
% The system is sensitive to perturbations.
% When the initial guess is too good, the algorithm shows the warning, but still calculated the correct result.
% Either choose a different initial guess or take into account that the first step has an inaccurate result.
% When you have concluded that your problem really merits a solution as is, and there is a good reason to need 
% to solve the problem DESPITE the numerical singularity, then you can use pinv. Thus, instead of A\b, 
% use pinv(A)*B. Pinv has some different properties than backslash. One reason why pinv is not used as a 
% default always is that it will be slower, sometimes significantly slower. Nobody wants slow code.



% https://www.mathworks.com/matlabcentral/answers/...
% 40375-question-on-optimization-problem-and-fminsearch-fminunc-lsqnonlin
% https://stackoverflow.com/questions/24360774/matlab-fminsearch-hessians
% https://www.mathworks.com/matlabcentral/answers/90374-fminsearch-finds-local-minimum-when-fminunc-does-not
% https://www.mathworks.com/matlabcentral/answers/330290-warning-matrix-is-close-to-singular-or-badly-scaled

% https://www.mathworks.com/help/optim/ug/optimization-decision-table.html
% https://www.mathworks.com/help/optim/ug/hessian.html#bsapedg
% https://www.mathworks.com/help/optim/ug/fminunc.html
% https://www.mathworks.com/help/optim/ug/unconstrained-nonlinear-optimization-algorithms.html#f171

% https://www.mathworks.com/help/matlab/ref/rcond.html