# 📸 CamPhish

> Grab cam shots and GPS location from the target's phone front camera or PC webcam — just by sending a link.

---

## ❓ What is CamPhish?
CamPhish is a penetration testing tool that hosts a fake website on a built-in PHP server and uses **Ngrok** & **Cloudflare Tunnel** to generate a shareable URL.  
When the target opens this URL and grants camera permission, CamPhish silently captures cam shots from the target’s device.

> ⚠️ Use responsibly — strictly for ethical hacking, security testing, and educational purposes.

---

## ✨ Features
✅ Grab cam shots from front camera / webcam  
✅ GPS location tracking with Google Maps integration  
✅ Three engaging webpage templates:
- Festival Wishing
- Live YouTube TV
- Online Meeting (Beta)

✅ Improved architecture support (ARM, ARM64, x86, x86_64, Apple Silicon)  
✅ Cleanup script to remove logs & captured files

---

## 🧪 Tested On
- ✅ Kali Linux
- ✅ Termux (Android)
- ✅ Ubuntu
- ✅ Parrot Sec OS
- ✅ macOS (Intel & Apple Silicon)
- ✅ Windows (via WSL)

---

## ⚙️ Installation & Setup

### Step 1: Install dependencies
```bash
apt-get -y install php wget unzip