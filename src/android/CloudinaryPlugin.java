package org.apache.cordova.cloudinary;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.cloudinary.Cloudinary;
import com.cloudinary.Transformation;

public class CloudinaryPlugin extends CordovaPlugin {

    private static final String _DATA = "_data";

	@Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        PluginResult pluginResult = null;

        try {
            //Create cloudinary connection
            Cloudinary cloudinary = this.CreateCloudinary(args);

            //Get the image Path form the parameters
            //This is a device URI (returned by the camera plugin with destinationType : Camera.DestinationType.FILE_URI)
            String imagePath = args.getString(0);

            //Create a file input stream based on the image path
            InputStream stream = getInputStreamFromUriString(imagePath, this.cordova);

            //Create the upload map options map
            Map uploadOptionsMap = this.CreateUploadOptions(args);

            //Upload the image to cloudinary
            JSONObject result = cloudinary.uploader().upload(stream, uploadOptionsMap);

            //Validate the upload result (by checking the public_id generated)
            String publicId = result.getString("public_id");
            if(publicId != null && !publicId.isEmpty()) {

                //Flag the response as "success"
                result.put("success", true);

                //Build the cordova plugin response
                pluginResult = new PluginResult(PluginResult.Status.OK, result);
            }
            else {
                //Flag the response as "not success"
                result.put("success", false);

                //Build the cordova plugin response
                pluginResult = new PluginResult(PluginResult.Status.ERROR, result);
            }
        }
        catch (Exception e) {
            JSONObject json = new JSONObject();
            json.put("success", false);
            json.put("message", e.getMessage());
            pluginResult = new PluginResult(PluginResult.Status.ERROR, json);
        }

        callbackContext.sendPluginResult(pluginResult);
        return true;
    }

    //Initialize cloudinary connection
    private Cloudinary CreateCloudinary(JSONArray args) throws JSONException {

        JSONObject cloudinarySettings = args.getJSONObject(3);
        Cloudinary cloudinary = null;

        //Check if cloudinary data come into the parameters (development mode)
        if(cloudinarySettings != null && cloudinarySettings.has("cloudName") && cloudinarySettings.has("apiKey") && cloudinarySettings.has("apiSecret")) {
            Map config = new HashMap();
            config.put("cloud_name", cloudinarySettings.getString("cloudName"));
            config.put("api_key", cloudinarySettings.getString("apiKey"));
            config.put("api_secret", cloudinarySettings.getString("apiSecret"));
            cloudinary = new Cloudinary(config);
        }
        else {
            //There is no cloudinary data as parameter, we grab them from the ApplicationManifest (production mode)
            Context context = this.cordova.getActivity().getApplicationContext();
            cloudinary = new Cloudinary(context);
        }

        return cloudinary;
    }

    private Map CreateUploadOptions(JSONArray args) throws JSONException {

        //Create the upload map options map
        Map uploadOptionsMap = new HashMap();

        //Image measures
        JSONObject measures = args.getJSONObject(1);
        if(measures != null && measures.has("width") && measures.has("height")) {

            int width = measures.getInt("width");
            int height = measures.getInt("height");
            Transformation trans = new Transformation();
            uploadOptionsMap.put("transformation", trans.width(width).height(height).generate().toString());
        }

        //Tags
        String tags = args.getString(2);
        if (tags != null && !tags.isEmpty()) {
            uploadOptionsMap.put("tags", tags);
        }

        return uploadOptionsMap;
    }

    public static String getRealPath(String uriString, CordovaInterface cordova) {
        String realPath = null;

        if (uriString.startsWith("content://")) {
            String[] proj = { _DATA };
            Cursor cursor = cordova.getActivity().managedQuery(Uri.parse(uriString), proj, null, null, null);
            int column_index = cursor.getColumnIndexOrThrow(_DATA);
            cursor.moveToFirst();
            realPath = cursor.getString(column_index);
            if (realPath == null) {
                //LOG.e(LOG_TAG, "Could get real path for URI string %s", uriString);
            }
        } else if (uriString.startsWith("file://")) {
            realPath = uriString.substring(7);
            if (realPath.startsWith("/android_asset/")) {
                //LOG.e(LOG_TAG, "Cannot get real path for URI string %s because it is a file:///android_asset/ URI.", uriString);
                realPath = null;
            }
        } else {
            realPath = uriString;
        }

        return realPath;
    }


    public static InputStream getInputStreamFromUriString(String uriString, CordovaInterface cordova) throws IOException {
        if (uriString.startsWith("content")) {
            Uri uri = Uri.parse(uriString);
            return cordova.getActivity().getContentResolver().openInputStream(uri);
        } else if (uriString.startsWith("file://")) {
            int question = uriString.indexOf("?");
            if (question > -1) {
                uriString = uriString.substring(0,question);
            }
            if (uriString.startsWith("file:///android_asset/")) {
                Uri uri = Uri.parse(uriString);
                String relativePath = uri.getPath().substring(15);
                return cordova.getActivity().getAssets().open(relativePath);
            } else {
                return new FileInputStream(getRealPath(uriString, cordova));
            }
        } else {
            return new FileInputStream(getRealPath(uriString, cordova));
        }
    }
}
