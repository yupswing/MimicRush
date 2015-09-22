#run from app root
if [[ ! -f .android ]] ; then
    echo 'chdir to scripts/android to run this script'
    exit
fi
version="1.2.0"; #TODEPLOY

mkdir -p ../../deploy/$version/;

cp ../../Export/android/bin/bin/Mimic\ Rush-release.apk ../../deploy/$version/
