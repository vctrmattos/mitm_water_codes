# Design and Detection of Covert Man-in-the-Middle Cyberattacks on Water Treatment Plants

This repository supports the simulations and evaluations presented in our research paper on covert man-in-the-middle (MitM) attacks against industrial control systems, specifically targeting water treatment processes.

## 📄 Abstract

Cyberattacks targeting critical infrastructure — such as water treatment facilities — represent significant threats to public health, safety, and the environment. This paper introduces a systematic framework for modeling and assessing covert man-in-the-middle (MitM) attacks that leverage system identification techniques to inform the attack design. We focus on the attacker’s ability to deploy a covert controller, and we evaluate countermeasures based on the state-of-the-art Process-Aware Stealthy Attack Detection (PASAD) anomaly detection method. Using a second-order linear time-invariant with time delay model, representative of water treatment dynamics, we design and simulate stealthy attacks. Our results highlight how factors such as system noise and inaccuracies in the attacker’s plant model influence the attack’s stealthiness, underscoring the need for more robust detection strategies in industrial control environments.

---

## 🚀 How to Use

1. **Set Parameters**  
   All system, attack, and detection parameters are defined in `params.m` and returned as a struct.

2. **Run Simulations**  
   Use one of the following scripts depending on your desired analysis:
   - `simulate_gamma.m`: vary only the attack magnitude (`gamma`)
   - `simulate_gamma_and_error.m`: vary both `gamma` and attacker model mismatch
   - `simulate_gamma_and_noise.m`: vary both `gamma` and system noise level

3. **View Results**  
   Visual outputs and confusion matrices are automatically generated using:
   - `plot_confusion_metrics.m`
   - `plot_heatmap.m`
   - `plot_max_detector.m`

4. **Reproduce Figures**  
   Saved `.mat` files (e.g., `results_model_error.mat`) contain all raw results and can be reloaded for plotting and analysis.

---

## 🛠 Requirements

- MATLAB R2021a or later
- Simulink
