import pandas as pd

df = pd.read_csv("fraudTrain.csv")

sample = df.sample(5000)

sample.to_csv("fraud_sample.csv", index=False)

print("Sample dataset created")