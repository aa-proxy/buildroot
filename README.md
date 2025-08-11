# 🛠️ Buildroot for [aa-proxy-rs](https://github.com/aa-proxy/aa-proxy-rs)

This repository contains the build system (based on Buildroot) used for building [aa-proxy](https://github.com/aa-proxy/aa-proxy-rs) images.

## 🚀 Quick Start (Example: Raspberry Pi Zero 2 W)

```bash
git clone --recurse-submodules https://github.com/aa-proxy/buildroot
cd buildroot
./docker-dev build
./docker-dev rpi02w
```

## 🐳 Interactive development (container shell)
If you want more control, you can enter an interactive shell inside the development container:

```
./docker-dev shell
```
Once inside, you can manually run builds like this:

```
./build-image.sh rpi02w
```
Useful for testing, debugging, or tweaking the environment without restarting the whole process.

## 📦 Available Configurations
All supported board/device configurations can be found here:  
👉 [external/configs](https://github.com/aa-proxy/buildroot/tree/main/external/configs) on GitHub

## 💾 Output Image
After a successful build, the final SD card image (for above example) will be located at:

```
buildroot/output/rpi02w/images/sdcard.img
```
You can flash this image directly to an SD card using dd, [balenaEtcher](https://etcher.balena.io/) or whatever flash tool you like.
