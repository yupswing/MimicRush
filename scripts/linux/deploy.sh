#run from app root
if ! [ -f .linux ] ; then
    echo 'chdir to scripts/linux to run this script'
    exit
fi
version="1.2.0"; #TODEPLOY

mkdir -p ../../deploy/$version/;

cp -aR ../../Export/linux/cpp/bin Mimic\ Rush &&
tar -c -f mimicrush32-$version.tar Mimic\ Rush &&
gzip mimicrush32-$version.tar &&
mv mimicrush32-$version.tar.gz ../../deploy/$version/;
rm -rf Mimic\ Rush;

cp -aR ../../Export/linux64/cpp/bin Mimic\ Rush &&
tar -c -f mimicrush64-$version.tar Mimic\ Rush &&
gzip mimicrush64-$version.tar &&
mv mimicrush64-$version.tar.gz ../../deploy/$version/;
rm -rf Mimic\ Rush;
