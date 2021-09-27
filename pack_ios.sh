mkdir Payload
cp -r ./build/ios/iphoneos/Runner.app ./Payload
zip -r ./build/ios/iphoneos/Payload.zip ./Payload
mv ./build/ios/iphoneos/Payload.zip ./build/ios/iphoneos/faith.uchidakotori.biliAnimeSearch.ipa
rm -r ./Payload

echo "ipa packed to ./build/ios/iphoneos/faith.uchidakotori.biliAnimeSearch.ipa"