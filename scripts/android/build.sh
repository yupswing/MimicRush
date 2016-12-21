#run from app root
if [[ ! -f .android ]] ; then
    echo 'chdir to scripts/android to run this script'
    exit
fi
cd ../../
lime build android -Dv2 -Dlegacy -Drelease
