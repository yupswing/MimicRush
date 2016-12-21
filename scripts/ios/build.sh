#run from app root
if [[ ! -f .ios ]] ; then
    echo 'chdir to scripts/ios to run this script'
    exit
fi
echo 'Wait until first output then CTRL+C';
echo 'After compile and deploy from Xcode';
cd ../../;
lime build ios -Dv2 -Dlegacy -Drelease;
