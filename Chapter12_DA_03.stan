data {
  int<lower=0> N;                 // データ数
  vector[N] lnq;                  // 目的変数
  vector[N] lnp;                  // 説明変数1 (連続)
  vector[N] capacity;             // 説明変数2 (連続)
  vector[N] date;                 // 説明変数3 (連続)
  int<lower=1, upper=42> brand[N];
  int<lower=1, upper=2> place[N];
  int<lower=0> n_brand;            // brandのカテゴリ数
  int<lower=0> n_place;            // placeのカテゴリ数
}

parameters {
  // 共通パラメータ
  real delta;                        // capacityの係数
  real<lower=0> sigma_q;             // 目的変数の標準偏差

  // 階層の事前分布パラメータ（各グループの平均と標準偏差）
  real mu_alpha;
  real<lower=0> sigma_alpha;
  real mu_beta;
  real<lower=0> sigma_beta;
  real mu_gamma;
  real<lower=0> sigma_gamma;

  // 非中心化のための生パラメータ (各グループの係数の標準正規分布からのズレ)
  vector[n_brand * n_place] alpha_raw;
  vector[n_brand * n_place] beta_raw;
  vector[n_brand * n_place] gamma_raw;
}

transformed parameters {
  // 生パラメータを変換して、実際の階層パラメータを生成
  vector[n_brand * n_place] alpha;
  vector[n_brand * n_place] beta;
  vector[n_brand * n_place] gamma;
  
  // 各データポイントの平均muを計算するためのベクトル
  vector[N] mu;
  
  // 非中心化による変換
  for (i in 1:(n_brand * n_place)) {
    alpha[i] = mu_alpha + sigma_alpha * alpha_raw[i];
    beta[i]  = mu_beta + sigma_beta * beta_raw[i];
    gamma[i] = mu_gamma + sigma_gamma * gamma_raw[i];
  }
  
  // muの計算
  for (i in 1:N) {
    // brandとplaceの組み合わせから、階層パラメータのインデックスを計算
    int combined_index = (brand[i] - 1) * n_place + place[i];
    
    // 線形予測子mu[i]の計算
    mu[i] = alpha[combined_index] 
          + delta * capacity[i] 
          + beta[combined_index] * lnp[i] 
          + gamma[combined_index] * date[i];
  }
}

model {
  // 階層の事前分布パラメータの事前分布
  mu_alpha ~ normal(0, 10);
  mu_beta ~ normal(0, 10);
  mu_gamma ~ normal(0, 10);
  sigma_alpha ~ cauchy(0, 5);
  sigma_beta ~ cauchy(0, 5);
  sigma_gamma ~ cauchy(0, 5);
  
  // 共通パラメータの事前分布
  delta ~ normal(0, 10);
  sigma_q ~ cauchy(0, 5);
  
  // 非中心化のための生パラメータに標準正規分布を割り当てる
  alpha_raw ~ normal(0, 1);
  beta_raw ~ normal(0, 1);
  gamma_raw ~ normal(0, 1);

  // 尤度関数 (目的変数のモデル)
  lnq ~ normal(mu, sigma_q);
}
