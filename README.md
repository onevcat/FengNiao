<p align="center">
<img src="https://raw.githubusercontent.com/onevcat/FengNiao/assets/logo.png" alt="FengNiao" title="FengNiao" width="468"/>
</p>

<p align="center">
<a href="https://travis-ci.org/onevcat/FengNiao"><img src="https://img.shields.io/travis/onevcat/FengNiao/master.svg"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/swift-4.0+-brightgreen.svg"/></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-ready-orange.svg"></a>
<a href="https://raw.githubusercontent.com/onevcat/Kingfisher/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/Kingfisher.svg?style=flat"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/platform-macos%20|%20Linux-blue.svg"/></a>
<a href="https://codecov.io/gh/onevcat/Hedwig"><img src="https://codecov.io/gh/onevcat/Hedwig/branch/master/graph/badge.svg"/></a>
</p>

## What

FengNiao is a simple command-line util to delete unused image resource files from your Xcode project.

## How

### Install

#### Mint

[Mint](https://github.com/yonaskolb/Mint) is a tool that installs and runs Swift command line tool packages. Make sure
you have Xcode installed, then:

```sh
> brew install mint
> mint install onevcat/fengniao
```

#### Compile from source

```bash
> git clone https://github.com/onevcat/FengNiao.git
> cd FengNiao
> swift build -c release

# Then copy the executable to your PATH, such as `/usr/local/bin`
> sudo cp .build/release/FengNiao /usr/local/bin/fengniao
```

FengNiao should be compiled, tested and installed into the `/usr/local/bin`.

### Usage

Just navigate to your project folder, then:

```shell
> fengniao
```

It will scan current folder and all its subfolders to find unused images, then ask you whether you want to delete them. Please make sure you have a backup or a version control system before you deleting the images; it will be an un-restorable operation.

FengNiao supports some arguments. You can find it by:

```shell
> fengniao --help

  -p, --project:
      Root path of your Xcode project. Default is current folder.
  --force:
      Delete the found unused files without asking.
  -e, --exclude:
      Exclude paths from search.
  -r, --resource-extensions:
      Resource file extensions need to be searched. Default is 'imageset jpg png gif pdf'
  -f, --file-extensions:
      In which types of files we should search for resource usage. Default is 'm mm swift xib storyboard'
  --skip-proj-reference:
      Skip the Project file (.pbxproj) reference cleaning.
      By skipping it, the project file will be left untouched. 
      You may want to skip ths step if you are trying to build multiple projects with dependency and keep .pbxproj unchanged while compiling.
  --version:
      Print version.
  -h, --help:
      Print this help message.
```

A more daily-work usage under a project could be:

```shell
> fengniao --project . --exclude Carthage Pods
```

This will search in current folder, but skip the `Carthage` and `Pods` folder, in which there might be some third party resources you do not want to touch.

### Use with Xcode build phase

It is easy to integrate FengNiao into your Xcode build process. By doing so, you could ensure your project being cleaned every time you build your project. 

Add a "Run Script" phase in the Build Phases tab:

![](http://i.imgur.com/Un8oYx7.png)

Then drag it above of "Copy Bundle Resources", editing its content to something like this:

```bash
fengniao --exclude Carthage --force
```

It is recommended to exclude vendor's folders like Pods or Carthage. Since you do not have a chance to confirm the result, you also need to add `--force` option.

### App Version

An GUI app version of FengNiao is also available. You can find it under the [App folder](https://github.com/onevcat/FengNiao/tree/master/App). We do not provide a pre-built binary for it. If needed, please build it by yourself. Thank you for @ldakhoa's contribution!

![](https://github.com/onevcat/FengNiao/assets/1019875/fef5874b-b114-42c6-9ce5-0420460180ab)

## How it works

1. Extract resource file names (default file type: `["imageset", "jpg", "png", "gif", "pdf"]`) in these folders `["imageset", "launchimage", "appiconset", "bundle”]`.
2. Use regular expression to search all string names in files (default files type: `["m", "mm", "swift", "xib", "storyboard", "plist"]`).
3. Exclude all used string names from resources files, we get all unused resources files.


## License and Information

FengNiao is open-sourced as MIT license. The name of this project comes from the Chinese word 蜂鸟 (hummingbird), which is the smallest bird in the world.

Submit [an issue](https://github.com/onevcat/FengNiao/issues/new) if you find something wrong. Pull requests are warmly welcome, but I suggest to discuss first.

You can also follow and contact me on [Twitter](http://twitter.com/onevcat) or [Sina Weibo](http://weibo.com/onevcat).

## Learning to Create

I streamed the way I created this tool as a live-coding session in a live platform in China. You can learn how to create a project with Swift Package Manager, how to apply Protocol-Oriented Programming (POP) in the project, and how to develop in a BDD way as well as write good tests there. 

It is a paid series lesson in Chinese. If you are interested in it, please check and watch the links below:

#### 现场编程 - 用 Swift 创建命令行工具 fengniao-cli

- [Part 1](http://m.quzhiboapp.com/?liveId=391&fromUserId=12049)
- [Part 2](http://m.quzhiboapp.com/?liveId=401&fromUserId=12049)
- [Part 3](http://m.quzhiboapp.com/?liveId=409&fromUserId=12049)


