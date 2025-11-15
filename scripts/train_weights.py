#!/usr/bin/env python3
import numpy as np

# Tiny synthetic dataset
X = np.array([[1.0, 0.5, 0.0, 0.0],
              [0.0, 0.2, 0.8, 0.1],
              [0.5, 0.5, 0.5, 0.5]], dtype=np.float32)
y = np.array([[1, 0],
              [0, 1],
              [1, 1]], dtype=np.float32)

# Simple 4-8-8-2 network
np.random.seed(42)
W1 = np.random.randn(4, 8) * 0.5
W2 = np.random.randn(8, 8) * 0.5
W3 = np.random.randn(8, 2) * 0.5
b1 = np.zeros((8,))
b2 = np.zeros((8,))
b3 = np.zeros((2,))

def relu(x): return np.maximum(0, x)
def forward(x):
    h1 = relu(x @ W1 + b1)
    h2 = relu(h1 @ W2 + b2)
    out = h2 @ W3 + b3
    return out

# Train 1000 epochs
for epoch in range(1000):
    h1 = relu(X @ W1 + b1)
    h2 = relu(h1 @ W2 + b2)
    out = h2 @ W3 + b3
    err = out - y
    # Backprop (simplified)
    dW3 = h2.T @ err
    db3 = np.sum(err, axis=0)
    dh2 = err @ W3.T * (h2 > 0)
    dW2 = h1.T @ dh2
    db2 = np.sum(dh2, axis=0)
    dh1 = dh2 @ W2.T * (h1 > 0)
    dW1 = X.T @ dh1
    db1 = np.sum(dh1, axis=0)

    lr = 0.01
    W1 -= lr * dW1; b1 -= lr * db1
    W2 -= lr * dW2; b2 -= lr * db2
    W3 -= lr * dW3; b3 -= lr * db3

# Quantize to Q8.8 and write hex
def q88(x): return int(round(x * 256)) & 0xFFFF

with open("../weights/weights.hex", "w") as f:
    for w in np.concatenate([W1.flatten(), b1, W2.flatten(), b2, W3.flatten(), b3]):
        f.write(f"{q88(w):04X}\n")

print("Weights exported to weights.hex")
