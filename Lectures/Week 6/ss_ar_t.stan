data {
  int<lower=0> N;
  int<lower=0> n_pos;
  vector[n_pos] y;
  int pos_indx[n_pos+2];
}
parameters {
  real x0;
  real<lower=-0.999,upper=0.999> phi;
  vector[N-1] pro_dev;
  real<lower=0> sigma_process;
  real<lower=0> sigma_obs;
  real<lower=2> nu;
}
transformed parameters {
  vector[N] pred;
  pred[1] = x0;
  for(i in 2:N) {
    pred[i] = phi*pred[i-1] + sigma_process*pro_dev[i-1];
  }
}
model {
  x0 ~ normal(0,10);
  phi ~ normal(0,1);
  sigma_process ~ student_t(3,0,2);
  sigma_obs ~ student_t(3,0,2);
  nu ~ student_t(3, 2, 3);
  pro_dev ~ student_t(nu, 0, 1);
  //pro_dev ~ std_normal();
  for(i in 1:n_pos) {
    y[i] ~ normal(pred[pos_indx[i]], sigma_obs);
  }
}
generated quantities {
  vector[n_pos] log_lik;
  // regresssion example in loo() package
  for (n in 1:n_pos) log_lik[n] = normal_lpdf(y[n] | pred[pos_indx[n]], sigma_obs);
}