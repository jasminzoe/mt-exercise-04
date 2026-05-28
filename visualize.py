import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("beam_results.csv")

plt.figure()
plt.plot(df["beam_size"], df["bleu"], marker="o")

plt.xlabel("Beam Size")
plt.ylabel("BLEU Score")
plt.title("Impact of Beam Size on BLEU Score")
plt.grid(True)

plt.savefig("beam_bleu.png")

plt.figure()
plt.plot(df["beam_size"], df["time_seconds"], marker="o")

plt.xlabel("Beam Size")
plt.ylabel("Generation in Seconds")
plt.title("Impact of Beam Size on Runtime")
plt.grid(True)

plt.savefig("beam_time.png")

