# FengNiao

## What

FengNiao is a simple command-line util to deleting unused image resource files from you Xcode project.

## How

### Install

You need Swift Package Manager (as well as swift compiler) installed in your macOS, generally you are prepared if you have the latest Xcode installed.

#### Compile from source

```bash
> git clone https://github.com/onevcat/FengNiao.git
> cd FengNiao
> ./install.sh
```

FengNiao should be compiled, tested and installed into the `/usr/local/bin`.

#### Homebrew

You may want to install in from Homebrew. But for now it is not supported.

### Usage

Just navigate to your project folder, then:

```bash
> fengniao
```

It will scan current folder and all its subfolders to find unused images, then ask for you whether you want to delete them. Please make sure you have a backup or a version control system before you deleting the images, it will be an un-restorable operation.

FengNiao supports some arguments, you could find it by:

```bash
> fengniao --help

  -p, --project:
      Root path of your Xcode project. Default is current folder.
  --force:
      Delete the found unused files without asking.
  -e, --exclude:
      Exclude paths from search.
  -r, --resource-extensions:
      Resource file extensions need to be searched. Default is 'imageset jpg png gif'
  -f, --file-extensions:
      In which types of files we should search for resource usage. Default is 'm mm swift xib storyboard'
  -h, --help:
      Prints this help message.
```

### Use with Xcode build phase

It is easy to integrate FengNiao into your Xcode build process. By doing so, you could ensure your project being cleaned every time you build your project. 

Add a "Run Script" phase in the Build Phases tab:

![](http://i.imgur.com/Un8oYx7.png)

Then drap it above of "Copy Bundle Resources", editing its content to something like this:

```
fengniao --exclude Carthage vendor --force
```

It is recommended to exclude vender's folders like Pods or Carthage. Since you do not have a chance to confirm the result, you also need to add `--force` option.




