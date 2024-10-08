# Social Media App

A simple social media project app made with Flutter wrapped in simple and beautiful design. 

## Stack

* Flutter as front end

* Node.js as backend server

* PostgreSQL as database

* Firebase as authentication medium and cloud storage for videos

* Appwrite as cloud storage for images

* Custom class as primary state management

## Setting up Firebase

* Create a Firebase project and then create a Firebase app

* Initialize authentication by enabling `email and password` authentication

* Initialize cloud storage by setting up Firebase Storage and allowing permissions

* Download the `google-services.json` file from the app and move it to the `android/app/` directory

* Add the package `flutterfire_cli` to your project then run `flutterfire configure`

* Select your project and `android` option then `firebase_options.dart` file will be created. Move it to the `lib/firebase` folder.

## Features

* Skeleton loading

* Sign up and login

* Email verification during sign up

* Uploading posts and comments

* Uploading images and videos

* Tagging other users and hashtags

* Deleting posts and comments

* Editing posts and comments

* Liking posts and comments

* Bookmarking posts and comments

* Viewing comments of a post or a comment

* Search posts and users

* Lock account / set as private

* Mute other users

* Block other users

* Notifications

* Private message

* Group message

* Edit group profile

* Add other users to group

* Auto login

## Basic preview of the application

![Social media app preview](https://github.com/joec05/files/blob/main/social_media_app/demo_1.png?raw=true "Social media app preview 1")

![Social media app preview](https://github.com/joec05/files/blob/main/social_media_app/demo_2.png?raw=true "Social media app preview 2")

## Things to fix and improve

* Database still cannot handle 1 million rows yet

* Adding more options of files to upload such as audio and PDF

* Adding push notifications

* Fix the nested scrolling bug in the profile page 

* Make improvements to cloud storage management
