# 📊 Plasma Command Output Metrics

A collection of **hardware-aware system metrics scripts** for  
**KDE Plasma’s Command Output widget**.

Designed for:
- Plasma 6
- Wayland
- Nerd Font icons
- minimal overhead
- no Python, no daemons

---

## ✨ Features

- CPU usage
- CPU temperature (multi-core aware)
- RAM, Swap, ZRAM usage
- Disk usage
- Network throughput (auto-detected interface)
- GPU usage (kernel-native where possible)
- Nerd Font icons for compact panel display

---

## 🧠 Philosophy

System metrics are **not universal**.

Different hardware requires different approaches:
- Intel vs AMD
- iGPU vs dGPU
- RC6 vs sysfs vs vendor tools
- laptops vs desktops

This repository therefore uses **hardware profiles** instead of one fragile script.

---

## 📁 Repository Structure Example

profiles/

├── intel-skylake-ult/

│   └── metrics.sh

├── amd-ryzen-apu/

│   └── metrics.sh

├── nvidia-desktop/

│   └── metrics.sh

└── generic/

    └── metrics.sh


Each profile targets a **specific hardware family**.

---

## 💻 Supported Hardware (initial)

### Intel Skylake U-Series (Ultrabooks)
- CPU: i5-6200U, i7-6500U, i7-6600U
- GPU: Intel HD 520 (Gen9)
- Kernel GPU metrics via RC6 residency

Profile:

profiles/intel-skylake-ult/

---

## 📦 Requirements

- KDE Plasma 6.x
- Command Output widget  
  👉 https://github.com/Zren/plasma-applet-commandoutput
- Nerd Font (recommended)
  ```bash
  sudo pacman -S ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono

## Optional (per profile)

Depending on the hardware profile, the following tools may be used:

- `lm_sensors`
- `perf`
- `intel-gpu-tools`
- `jq`

---

## 🧩 Usage

1. Install the **Command Output** widget  
   👉 https://github.com/Zren/plasma-applet-commandoutput

2. Add it to your KDE Plasma panel

3. Set the command to a hardware profile script, for example:

   ```bash
   ~/plasma-commandoutput-metrics/profiles/intel-skylake-ult/metrics.sh

4. Set the update interval:
    1–2 seconds (depending on script complexity)


---

## 🚧 Contributing

Contributions are welcome.

Please follow these guidelines:

- Add new hardware as separate profiles
- Clearly document kernel interfaces used
- Avoid vendor-specific userland tools where possible

---

## 📜 License

MIT

---

## Summary

- **Repository:** `plasma-commandoutput-metrics`
- **Description:**  
  *Hardware-aware system metrics scripts for KDE Plasma Command Output widget*
- **Profile directory for this system:**  
  `profiles/intel-skylake-ult/`

---

If you want to continue, next steps could be:

- an `install.sh` with profile selection
- automatic hardware detection (`lscpu`, `lspci`)
- an additional profile for another machine (e.g. your Ryzen laptop `heisenberg`)

---

If you want, I can also provide next:

- the **auto-detection concept** as Markdown
- a **profile matrix table** (CPU/GPU → profile)
- or a **contribution template** (`CONTRIBUTING.md`)
