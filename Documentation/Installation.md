## Installation

#### Git submodules

1) Run `git submodule add http://github.com/jwfriese/Fleet`

2) Add `Fleet.xcodeproj` to your project file

3) In your test target, navigate to the `Link Binary with Libraries` section, and add `Fleet.framework`.

4) *(The following step is only necessary if you are using Fleet's storyboard-related features)*
To your test target, add a `Run Script`. The script will run a shell script included in Fleet source. For example, if you added the submodule like this:

`git submodule add http://github.com/jwfriese/Fleet Externals/Fleet`

The `Run Script` should look like this:

`$PROJECT_DIR/Externals/Fleet/Fleet/Script/copy_storyboard_info_files.sh`

#### Cocoapods

1) Include Fleet in your `Podfile`:
`pod 'Fleet'`

2) Run `pod install`

3) *(The following step is only necessary if you are using Fleet's storyboard-related features)*
To your test target, add a `Run Script`. The script will run a shell script preserved in the framework's Pod. Assuming your `Pods` directory is in your source root, your `Run Script` would look like this:

`"${SRCROOT}/Pods/Fleet/Fleet/Script/copy_storyboard_info_files.sh"`

#### Carthage
Include Fleet in your `Cartfile`:
`github "jwfriese/Fleet"`

For further reference see [Carthage's documentation](https://github.com/Carthage/Carthage/blob/master/README.md).
