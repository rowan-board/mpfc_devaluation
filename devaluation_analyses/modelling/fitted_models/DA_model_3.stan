/* RL directed action model 4 (two channel) : lr and tau
*  author: RB
*/

// The input data is a vector 'y' of length 'N'.
data {
     int<lower=1> N; 				//Number of subjects (strictly positive int)
     int<lower=1> T;  				//Number of trials (strictly positive int)
     int<lower=1, upper=T> Tsubj[N]; 		//Number of trials per subject (1D array of ints) — contains the max number of trials per subject
     int<lower=2> Nopt;				//Number of choice options per trial (int) — set to 2
     int<lower=2> Nrwd;       //number of rewards per option (int) - set to 2

     matrix[N,T] rwd;		//Matrix of reals containing the reward received on a given trial (1 or 0) — (rows: participants, columns : trials)
     matrix[Nrwd,Nopt] Qinits;		//Vector of reals containing the initial q-values for each option, combo of Vinits_2 (set to [0, 0] for now);
     vector[Nopt] Vinits;
     vector[Nrwd] Minits; // vector containing the initial motivation for both value types, initally set to [1,1]

     int<lower=0,upper=Nopt> choice[N,T]; 		 // Array of ints containing the choice made for each trial and participant (i.e. option chosen out of 2) — (rows: participants, columns: trials)
     int<lower=0,upper=2> winCurr[N,T];     // matrix containing the win currency, 0=nothing 1=green 2=red
     matrix<lower=0,upper=1>[N,T] isPurseFull_1; // matrix of reals informing us of whether purse 1 is full or not (1=yes)
     matrix<lower=0,upper=1>[N,T] isPurseFull_2; // matrix of reals informing us of whether purse 2 is full or not (1=yes)
     vector[N] blockStart;   // vector containing the trial number where the new block starts, and EVs should be reset
}

transformed data {
     matrix[Nrwd,Nopt] initQ;
     initQ = Qinits;
}

parameters {
     real<lower=0> a_lr;
     real<lower=0> b_lr;
     real<lower=0> k_tau;
     real<lower=0, upper=20> theta_tau;
     
     vector<lower=0, upper=1>[N] lr;
     vector<lower=0, upper=6>[N] tau;
}

transformed parameters {
     vector<lower=0>[N] inv_temp;

     inv_temp = 1 ./ tau;
}

model {
     a_lr ~ normal(1,5);
     b_lr ~ normal(1,5);

     k_tau ~ normal(0.8,20);
     theta_tau ~ normal(1,20);
     
     lr ~ beta(a_lr,b_lr);
     tau ~ gamma(k_tau,theta_tau);

     for (i in 1:N) {
       matrix[Nrwd,Nopt] Q;       // inital q values, matrix for options and reward types
       vector[Nopt] v;            // initial q values for options, reward types collapsed, for softmax
       vector[Nrwd] q;            // expected reward biased by motivation
       vector[Nrwd] qc;           // expected reward conuterfactual
       vector[Nrwd] pe;           // prediction error 
       vector[Nrwd] pec;          // prediction error counterfactual
       
       // initialise the value vectors to 0s
       v = Vinits;
       Q = Qinits;
       
       
       for (t in 1:(Tsubj[i])) {
         choice[i,t] ~ categorical_logit(inv_temp[i] * v);
         
         // update the value of the chosen option when a reward is received 
         
         if (rwd[i,t] == 1){
           pe[choice[i,t]] = rwd[i,t] - Q[winCurr[i,t],choice[i,t]];
           
           q[choice[i,t]] = 1 * (lr[i] * pe[choice[i,t]]);
           
           Q[winCurr[i,t],choice[i,t]] = Q[winCurr[i,t],choice[i,t]] + q[choice[i,t]];
         }
        
         
         // update value of the chosen option for both reward types when nothing is received 
         if (rwd[i,t] == 0){
           pe = rwd[i,t] - Q[,choice[i,t]];
           q = lr[i] * pe;
           Q[,choice[i,t]] = Q[,choice[i,t]] + q;
         }
         
         // collapse vectors and update v
         v[1] = (Q[1,1])+(Q[2,1]);
         v[2] = (Q[1,2])+(Q[2,2]);
         
         // reset the Ev's if the trial number hits the start of the new block
         if (t == blockStart[i]){
            v = Vinits;
            Q = Qinits;
         }
       }
     }
}

generated quantities{
  real log_lik[N];
  real pred[N,T];

  // Set all posterior predictions and trialwise log likelihoods to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:T) {
      pred[i, t] = -1;
      //trialwise_loglik[i,t] = -1;
    }
  }
  
       for (i in 1:N) {
       matrix[Nrwd,Nopt] Q;         // inital q values, matrix for options and reward types
       vector[Nopt] v;              // initial q values for options, reward types collapsed, for softmax
       vector[Nrwd] q;            // expected reward biased by motivation
       vector[Nrwd] qc;           // expected reward conuterfactual
       vector[Nrwd] pe;           // prediction error 
       vector[Nrwd] pec;          // prediction error counterfactual
       
       
       // initalise values
       v = Vinits;
       Q = Qinits;
       log_lik[i] = 0.0;
       
       
       for (t in 1:(Tsubj[i])) {
         
         log_lik[i] = log_lik[i] + categorical_logit_lpmf(choice[i,t] | inv_temp[i] * v);
         pred[i,t] = categorical_rng(softmax(inv_temp[i] * v));
         
         
         if (rwd[i,t] == 1){
           pe[choice[i,t]] = rwd[i,t] - Q[winCurr[i,t],choice[i,t]];
           
           q[choice[i,t]] = 1 * (lr[i] * pe[choice[i,t]]);
           
           Q[winCurr[i,t],choice[i,t]] = Q[winCurr[i,t],choice[i,t]] + q[choice[i,t]];
          
         }
         
         if (rwd[i,t] == 0){
           pe = rwd[i,t] - Q[,choice[i,t]];
           q = lr[i] * pe;
           Q[,choice[i,t]] = Q[,choice[i,t]] + q;
         }
         
         
         // collapse vectors and update v
         v[1] = (Q[1,1])+(Q[2,1]);
         v[2] = (Q[1,2])+(Q[2,2]);
         
         // reset the Ev's if the trial number hits the start of the new block
         if (t == blockStart[i]){
            v = Vinits;
            Q = Qinits;
         }
       }
     }
}

