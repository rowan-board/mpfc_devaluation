/* RL directed action model 1 (null_model): tau
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
     matrix<lower=0>[N,2] blockStart;   // vector containing the trial number where the new block starts, and EVs should be reset
     int<lower=0,upper=1> P[N];           // 1 is patient data and 0 is healthy should be reset
}

transformed data {
     vector[Nopt] initV;
     initV = Vinits;
}

parameters {
     real<lower=0> k_tau;
     real<lower=0, upper=20> theta_tau;

     vector<lower=0, upper=6>[N] tau;
}

transformed parameters {
     vector<lower=0>[N] inv_temp;

     inv_temp = 1 ./ tau;
}

model {
     k_tau ~ normal(0.8,20);
     theta_tau ~ normal(1,20);

     tau ~ gamma(k_tau,theta_tau);

     for (i in 1:N) {
             vector[Nopt] v;

             v = initV;

             for (t in 1:(Tsubj[i])) {
             		choice[i,t] ~ categorical_logit( inv_temp[i] * v );
             		
             		// reset the Ev's if the trial number hits the start of the new block
                // two blocks for the patient data, only 1 patient, turn blockstart into matrix if multiple
                if (P[i] == 0){
                  if (t == blockStart[i,1]){
                    v = initV;
                  }
                } else if (P[i] == 1){
                  if (t == blockStart[i,1] || t == blockStart[i,2]){
                    v = initV;
                  }
                }
             }
     }
}

generated quantities {
      real log_lik[N];

        for (i in 1:N) {
                  vector[Nopt] v;

                  v = initV;
                  log_lik[i] = 0;

                  for (t in 1:(Tsubj[i])) {
                    log_lik[i] = log_lik[i] + categorical_logit_lpmf( choice[i,t] | inv_temp[i] * v );
                    
                    // reset the Ev's if the trial number hits the start of the new block
                    // two blocks for the patient data, only 1 patient, turn blockstart into matrix if multiple
                    if (P[i] == 0){
                      if (t == blockStart[i,1]){
                        v = initV;
                      }
                    } else if (P[i] == 1){
                      if (t == blockStart[i,1] || t == blockStart[i,2]){
                        v = initV;
                      }
                    }
                  }
        }
}