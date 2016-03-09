# Cordova Cloudinary plugin

Integrates some of the [Cloudinary](http://cloudinary.com/) features into Cordova

## Installation

### With cordova-cli

If you are using [cordova-cli](https://github.com/apache/cordova-cli), install
with:

    cordova plugin add https://github.com/ElNinjaGaiden/org.apache.cordova.cloudinary -save

##Uploading images

```
var request     = {
    imagePath           : '<imagePath>',
    tags                : 'tag1, tag2, tag3',
    cloudinarySettings  : {
        cloudName   : '<CloudinaryCloudName>',
        apiKey      : '<CloudinaryApiKey>',
        apiSecret   : '<CloudinaryApiSecret>'
    }
}

navigator.cloudinary.uploadImage(request, function (uploadResponse) {
    //Success callback
    console.log('Cloudinary image plublic id', uploadResponse.public_id);
    console.log('Cloudinary image format', uploadResponse.format);
}, function (uploadError) {
    //Error callback
    console.error('Error', error);
});
