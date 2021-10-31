mkdir Payload
cp -r ./build/ios/Release-iphoneos/Runner.app ./Payload
zip -r ./build/ios/Release-iphoneos/Payload.zip ./Payload
mv ./build/ios/Release-iphoneos/Payload.zip ./build/ios/Release-iphoneos/faith.uchidakotori.biliAnimeSearch.ipa
rm -r ./Payload

echo "ipa packed to ./build/ios/Release-iphoneos/faith.uchidakotori.biliAnimeSearch.ipa"