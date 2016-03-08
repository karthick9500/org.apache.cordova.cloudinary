var exec = require('cordova/exec');

var cloudinary = {
    
    uploadImage: function (request, successCallback, errorCallback) {
        exec(successCallback, errorCallback, "CloudinaryPlugin", "uploadImage", [
                request.imagePath,
                request.measures || {},
                request.tags || '',
                request.cloudinarySettings || {}
            ]
        );
    }
};

module.exports = cloudinary;