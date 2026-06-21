import numpy as np
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.preprocessing import StandardScaler
import joblib
import os

np.random.seed(42)

# 1. Generate Synthetic Dataset
n_samples = 1000

# Features: attendance_rate (0-100), partial_score (0-100)
attendance = np.random.normal(85, 15, n_samples)
attendance = np.clip(attendance, 0, 100)

partial_score = np.random.normal(75, 18, n_samples)
partial_score = np.clip(partial_score, 0, 100)

# Target: final_score = 0.4*attendance + 0.6*partial_score + noise
noise = np.random.normal(0, 5, n_samples)
final_score = 0.4 * attendance + 0.6 * partial_score + noise
final_score = np.clip(final_score, 0, 100)

# Target for Logistic: passed (1 if final_score >= 51 else 0)
passed = (final_score >= 51).astype(int)

X = np.column_stack((attendance, partial_score))

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 2. Train Models
# Linear Regression
lin_reg = LinearRegression()
lin_reg.fit(X_scaled, final_score)

# Logistic Regression
log_reg = LogisticRegression()
log_reg.fit(X_scaled, passed) # We predict 'passed'. Failure probability is 1 - proba(passed)

# 3. Save Models
artifacts_dir = "/home/anjelmuser/in_rainbows/all_i_need/loombito-dev/server/app/modules/intelligence/models/artifacts"
os.makedirs(artifacts_dir, exist_ok=True)

joblib.dump(scaler, os.path.join(artifacts_dir, "base_scaler.pkl"))
joblib.dump(lin_reg, os.path.join(artifacts_dir, "base_linear_model.pkl"))
joblib.dump(log_reg, os.path.join(artifacts_dir, "base_logistic_model.pkl"))

print(f"Modelos base entrenados y guardados en {artifacts_dir}")
