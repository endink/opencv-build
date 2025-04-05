# OpenCV Static Build

This project is to build [OpenCV](https://opencv.org/) libraries which are not provided in [the official releases](https://github.com/opencv/opencv/releases).


### Build Scripts

Build for native:

```sh
./build-static_lib.sh
```


Build for windows

```cmd
.\build-static-win64
```



Build for android

```cmd
export ANDROID_HOME=~/Android
./setup_ndk.sh r25b
./build-android r25b static
```
