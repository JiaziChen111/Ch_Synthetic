function [logllk,xs,Ps,Pslag] = EM_Estep(y,mu_y,A,R,mu_x,Phi,Q)

    [logllk,xp,Pp,xf,Pf,xs,Ps,Pslag] = kfs(y,mu_y,A,R,mu_x,Phi,Q);
%     [params.MLE.s, ws, cs, loglik] = kalmansqrt(Y,params.A,params.B,params.R,params.E,params.F,params.Q,options);
%     params.MLE.sumws=sum(ws,3);             % Sums Ps matrices
%     params.MLE.ws1=ws(:,:,1);               % First Ps matrix
%     params.MLE.wsT=ws(:,:,params.T);        % Last Ps matrix
%     params.MLE.sumcs=sum(cs(:,:,2:end),3);  % Sums PSlag matrices 2 to end
%     params.X=params.MLE.s;                  % Saves xs as x
%     % compute statistics
%     params= betadeltagamma(Y,params);
end
