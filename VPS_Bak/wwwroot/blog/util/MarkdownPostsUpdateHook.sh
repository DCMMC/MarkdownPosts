#!/bin/sh

# Jekyll update hook

#GIT_REPO=https://github.com/DCMMC/DCMMC.github.io
GIT_REPO=https://github.com/DCMMC/Notes
TMP_GIT_CLONE=/tmp/blog/
SOURCE=/home/wwwroot/DCMMC.github.io
#user: Root!
PUBLIC_WWW=/home/wwwroot/blog/

git clone $GIT_REPO $TMP_GIT_CLONE 

#Clean old post
echo "clean1"
rm -Rf $SOURCE/_posts/*

# move
echo "move"
mv $TMP_GIT_CLONE/* $SOURCE/_posts/


#Clean
echo "clean2"
echo "Clean old htmls"
rm -Rf $PUBLIC_WWW* 

echo "build"

/usr/local/ruby/bin/jekyll build --source $SOURCE --destination $PUBLIC_WWW --incremental


#Clean
echo "clean3"

rm -Rf $TMP_GIT_CLONE
exit
