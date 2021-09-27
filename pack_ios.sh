mkdir ./build/ios/iphoneos/Payload
cp -r ./build/ios/iphoneos/Runner.app ./build/ios/iphoneos/Payload
zip -r ./build/ios/iphoneos/Payload.zip ./build/ios/iphoneos/Payload
mv ./build/ios/iphoneos/Payload.zip ./build/ios/iphoneos/faith.uchidakotori.biliAnimeSearch.ipa
rm -r ./build/ios/iphoneos/Payload

echo "ipa packed to ./build/ios/iphoneos/faith.uchidakotori.biliAnimeSearch.ipa"