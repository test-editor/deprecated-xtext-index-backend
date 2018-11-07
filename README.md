# DEPRECATED xtext-index-backend
xtext-index-backend

:warning: **WARNING** This project is deprecated because the Test-Editor Team decided to merge the newly created index backend with the existing Xtext backend in October 2018 :warning:

The new backend repository for the project :star:Test-Editor-Web:star: can be found under [test-editor-backend](https://github.com/test-editor/test-editor-backend) 

## build local version

`./gradlew install` will build a local version and put this into the local maven repository from which it can be used locally for other builds. The current version is set within the file `gradle.properties`

## publish version

- checkout master branch
- execute `./gradlew release` 
- done

This will run a complete build locally, run all tests locally and tag this branch to a version, pushing it into the master branch. Following
the push, a travis job will run that will run a complete build on ci (including tests etc.). Given the success of this run, travis will run
a publish script that checks whether a (new) tag is set and of so, runs an upload to bitbucket task with gradle that will do the actual
upload to bintray / jcenter.
