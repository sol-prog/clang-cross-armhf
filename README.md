Multistage Dockerfile to build Clang 8 as a crosss compiler for Raspberry Pi. See [Using Clang as a cross compiler for Raspberry Pi](https://solarianprogrammer.com/2019/05/04/clang-cross-compiler-for-raspberry-pi/) for more details.

If you are using Docker on macOS or Windows, make sure that it can use ***at least 4GB of RAM***, otherwise the build will fail (by default on macOS and Windows Docker will use 2GB of RAM which is not enough to build Clang).

Usage:

* Build the image:

```
git clone https://github.com/sol-prog/clang-cross-armhf.git
cd clang-cross-armhf
docker build -t clang-cross-debian-armhf .
```

* Optional, if you want to remove the intermediary images:

```
docker save -o cross.tar clang-cross-debian-armhf
docker image rm clang-cross-debian-armhf
docker load -i cross.tar
rm cross.tar
```

* Create a container:

```
docker run -it --name debian_clang clang-cross-debian-armhf /bin/bash
```

* Run an existing container:

```
docker start -ia debian_clang
```

After you've build the image and created a work container, see the end of my article for the post build steps [Using Clang as a cross compiler for Raspberry Pi - Post build steps](https://solarianprogrammer.com/2019/05/04/clang-cross-compiler-for-raspberry-pi/#post_build)
