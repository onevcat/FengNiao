#!/bin/sh
swift package clean
swift test
swift build -c release
cp .build/release/FengNiao /usr/local/bin/fengniao
