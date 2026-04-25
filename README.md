# 📊 System Metrics – KDE Plasma 6 Widget

A **native KDE Plasma 6 widget** that displays real-time system metrics
directly in your panel, with a detailed popup on click.

**Hardware-agnostic** – automatically detects your CPU, GPU, and sensors.

---

## ✨ Features

| Metric | Source | Notes |
|--------|--------|-------|
| **CPU Usage** | `/proc/stat` | Delta between widget refreshes |
| **CPU Temperature** | `lm_sensors` / sysfs | Intel Core, AMD Tctl/Tdie, thermal zones |
| **GPU Usage** | Auto-detected | Intel (RC6), AMD (`gpu_busy_percent`), NVIDIA (`nvidia-smi`) |
| **RAM** | `/proc/meminfo` | Used/Total in GB + percentage |
| **Swap** | `/proc/meminfo` | Hidden if 0% (configurable) |
| **ZRAM** | `/sys/block/zram0` | Hidden if not present |
| **Disk** | `df` | Root partition usage |
| **Network** | `/sys/class/net/` | Auto-detected interface, cached ↓/↑ throughput |

### Panel View (Compact)
Compact one-line display with Nerd Font icons and white values:

```
󰍛 23%  󰢮 5%   51°  󰘚 64%   18%  󰟜 4%  󰋊 45%  ↓1.2 MB/s ↑120 KB/s
```

### Popup View (Full)
Click the panel widget to see all metrics with animated progress bars,
detailed values (e.g. "5.2 / 15.5 GB"), and GPU type indicator.

### Configuration
Right-click → Configure to:
- Choose which metrics appear in the panel
- Toggle Swap/ZRAM in the panel when available
- Adjust panel icon size, text size, icon/value spacing, and metric spacing
- Set the update interval (1–10 seconds)
- Keep Swap/ZRAM visible in the detailed view even at 0%

---

## 📦 Installation

### Requirements
- KDE Plasma 6.x
- `plasma-sdk` (for `kpackagetool6`)
- Nerd Font (recommended): `sudo pacman -S ttf-nerd-fonts-symbols`

### Optional
- `lm_sensors` – for accurate CPU temperature
- `nvidia-smi` – for NVIDIA GPU monitoring (comes with NVIDIA drivers)

### Install

```bash
git clone https://github.com/willheisenberg/plasma-commandoutput-metrics.git
cd plasma-commandoutput-metrics
./install.sh
```

### Manual Install

```bash
kpackagetool6 -t Plasma/Applet -i plasmoid/
```

### Update

```bash
kpackagetool6 -t Plasma/Applet -u plasmoid/
```

### Uninstall

```bash
kpackagetool6 -t Plasma/Applet -r com.github.willheisenberg.systemmetrics
```

---

## 🖥️ Supported Hardware

### CPU
All x86/x86_64 CPUs (Intel and AMD) – uses `/proc/stat` which is universal.

### GPU
| Vendor | Method | Requirements |
|--------|--------|-------------|
| **Intel** (Gen6+) | RC6 residency via sysfs | None (kernel-native) |
| **AMD** (amdgpu) | `gpu_busy_percent` via sysfs | None (kernel-native) |
| **NVIDIA** | `nvidia-smi` query | `nvidia-smi` (included with NVIDIA drivers) |

### Temperature
| Vendor | Method |
|--------|--------|
| **Intel** | `sensors` → "Core X:" entries |
| **AMD Ryzen** | `sensors` → "Tctl" / "Tdie" entries |
| **Fallback** | `/sys/class/thermal/thermal_zone*/temp` |

---

## 🧩 Project Structure

```
plasmoid/
├── metadata.json                     # Widget metadata (Plasma 6)
└── contents/
    ├── ui/
    │   ├── main.qml                  # Entry point (PlasmoidItem)
    │   ├── CompactRepresentation.qml # Panel view
    │   └── FullRepresentation.qml    # Popup view
    ├── config/
    │   ├── main.xml                  # Configuration schema
    │   └── config.qml                # Configuration UI
    └── scripts/
        └── metrics.sh                # Hardware-agnostic metrics (JSON)
```

### Legacy Profiles
The original hardware-specific shell scripts remain in `profiles/` for
reference, but are no longer needed – the plasmoid's `metrics.sh` handles
all hardware automatically.

---

## 🚧 Contributing

Contributions are welcome! Please:

- Test on your hardware (especially non-Intel GPUs)
- Report which sensors/GPU methods work or fail
- Follow the existing code style

---

## 📜 License

MIT
