# VHDL Neural Network – FPGA-Ready MLP

A **fully synthesizable**, **parameterizable** feed-forward neural network implemented entirely in **VHDL**, with **Python-based training** and **fixed-point Q8.8 arithmetic**.

Designed for **FPGA deployment** (Xilinx, Intel, Lattice) or **ASIC prototyping**, this project bridges software ML and hardware acceleration.

---

## Features

- **3-layer MLP**: Input → Hidden(8) → Hidden(8) → Output(2) *(configurable)*
- **Fixed-point Q8.8** (16-bit) arithmetic – no floating point units needed
- **ReLU activation** in hidden layers, **linear** output
- **Weights loaded from `weights.hex`** at startup (simulation or synthesis)
- **Modular VHDL design** – easy to scale layers/neurons
- **Self-checking testbench** with file I/O
- **Python training script** using NumPy (plug in MNIST, CIFAR, etc.)

---

## Project Structure

```
vhdl-neural-network/
├── src/                # VHDL source files
│   ├── neuron.vhd      # Single neuron with MAC + ReLU
│   ├── layer.vhd       # Array of neurons
│   ├── network.vhd     # Top-level network
│   └── tb_network.vhd  # Testbench with weight loading
├── sim/                # Simulation waveforms (generated)
├── scripts/
│   └── train_weights.py  # Trains model & exports Q8.8 weights
├── weights/
│   └── weights.hex     # Trained weights in hex (130 lines)
├── .gitignore
├── LICENSE
└── README.md
```

---

## How It Works

1. **Python Script** (`train_weights.py`):
   - Trains a small MLP on synthetic (or real) data.
   - Quantizes weights/biases to **Q8.8**.
   - Writes one 16-bit hex value per line → `weights.hex`.

2. **VHDL Testbench**:
   - Reads `weights.hex` at simulation start.
   - Loads into ROM array.
   - Feeds input vector → computes output → reports result.

3. **Hardware**:
   - All operations are **pipelined/clocked**.
   - One layer computed per clock cycle (can be parallelized).
   - Ready for **Vivado/Quartus synthesis**.

---

## Quick Start

### 1. Train the Model
```bash
python scripts/train_weights.py
```
→ Generates `weights/weights.hex`

### 2. Simulate (GHDL)
```bash
cd src
ghdl -a *.vhd
ghdl -e tb_network
ghdl -r tb_network --wave=../sim/wave.ghw
```
Open `wave.ghw` in **GTKWave** to visualize signals.

### 3. Expected Output (example)
```text
Output: 325, -87
```
→ Interpreted as: `[1.27, -0.34]` in Q8.8

---

## Customization

| Parameter | File | How to Change |
|---------|------|---------------|
| Input size | `network.vhd` | `I_SIZE` |
| Hidden neurons | `network.vhd` | `H1_SIZE`, `H2_SIZE` |
| Output size | `network.vhd` | `O_SIZE` |
| Bit width | All `.vhd` | `WIDTH := 16` |
| Activation | `neuron.vhd` | Replace ReLU with sigmoid/tanh |

> Update Python script accordingly to match layer sizes.

---

## Synthesis Tips

- Use **Xilinx Vivado** or **Intel Quartus**.
- Add `weights.hex` as **coefficient file** or **memory initialization**.
- For real FPGA: replace file read with **Block RAM + init file**.
- Add AXI4-Stream interface for streaming inference.

---

## Example: Plug in MNIST

Replace training data in `train_weights.py`:
```python
from sklearn.datasets import load_digits
X, y = load_digits(return_X_y=True)
X = X / 16.0  # normalize
# one-hot encode y, etc.
```

---

## Contributing

1. Fork the repo
2. Create a feature branch
3. Submit a Pull Request

Ideas:
- Add sigmoid/tanh in fixed-point
- Parallelize layers
- Add Cocotb verification
- Generate Vivado IP core

---

## License

[MIT License](LICENSE) © [mohsensalehi1984](https://github.com/mohsensalehi1984)

---
- * I enjoy making HDL projects for AI and ML. If you like it or have any suggestions, let me know ! *
> **Built for learning, research, and real FPGA deployment.**
```
