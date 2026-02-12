# OpenCV Static Build

This project is to build [OpenCV](https://opencv.org/) libraries which are not provided in [the official releases](https://github.com/opencv/opencv/releases).


### Build Scripts

Build for linux:

```sh
./build-static_lib.sh
```


Build for windows (x64)

```cmd
.\build-windows
```



Build for android

run `build-android [ndk-version] [static/shared] [android api level]`

```cmd
export ANDROID_HOME=~/Android
./setup_ndk.sh r25b

./build-android.sh r25b static 21
```
