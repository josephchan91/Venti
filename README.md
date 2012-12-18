#Venti

A private and social sharing experience for all the stuff you would never put up on Facebook.

##Setup
To test the app out for yourself, you'll need to hook it up to Parse and Facebook. It's easy:

1. Create a free [Parse](https://parse.com/apps) account, and create a demo app.

2. Create a demo [Facebook app](https://developers.facebook.com/apps).

3. Go to the project's `AppDelegate.m` file, and fill in your Parse application id and client key:

```objective-c
[Parse setApplicationId:@"YOUR_PARSE_APP_ID" clientKey:@"YOUR_PARSE_CLIENT_KEY];"
```

5. Fill in your Facebook application id:

```objective-c
[PFFacebookUtils initializeWithApplicationId:@"YOUR_FB_APP_ID"];"
```

4. Select the project and navigate to the "Info" tab. Expand "URL Types" and press the "Add" button on the bottom left. Set the "URL Scheme" field to "fbYour_App_Id" (ex. fb1234567890).

##Acknowledgements
- [Parse](www.parse.com) for persisting objects (Users, Posts, Feed Items, Comments and Photos). Really easy and straightforward to use, with lots of helpful tutorials and sample apps. It also has the FacebookSDK baked in, which
I needed for dynamic friend searching and picking.
- [Glyphicons](glyphicons.com) for sweet (and free) icons.
