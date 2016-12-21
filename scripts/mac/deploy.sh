#run from app root
if [[ ! -f .mac ]] ; then
    echo 'chdir to scripts/mac to run this script'
    exit
fi
version="1.2.0"; #TODEPLOY

mkdir -p ../../deploy/$version/;

rm -rf ../../deploy/$version/mimicrush-$version.dmg;
cp MimicRush.sparseimage deploy.sparseimage &&
hdiutil attach deploy.sparseimage &&
cp -aR ../../Export/mac64/cpp/bin/Mimic\ Rush.app /Volumes/Mimic\ Rush &&
hdiutil detach disk3 &&
hdiutil convert deploy.sparseimage -format UDBZ -o ../../deploy/$version/mimicrush-$version.dmg;
rm deploy.sparseimage;
