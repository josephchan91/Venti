Venti
A private and social sharing experience for all the stuff you would never put up on Facebook. Logo is a bit too cute; suggestions welcome. 

To test the app out for yourself, you'll need to hook it up to Parse and Facebook. It's easy:
1. Create a free Parse account at www.parse.com, and create a demo app.
3. Create a demo Facebook app at https://developers.facebook.com/apps.
4. Go to this project's AppDelegate.m file, and fill in YOUR_PARSE_APP_ID, YOUR_PARSE_CLIENT_KEY, and YOUR_FB_APP_ID.
5. Select the project file (Venti) and navigate to the "Info" tab. Expand "URL Types" and press the "Add" button on the bottom left. Set the URL Scheme field to "fbYour_App_Id" (ex. fb1234567890).

Props to:
- Parse (www.parse.com) for persisting objects (Users, Posts, Feed Items, Comments and Photos). Really easy and straightforward to use, with lots of helpful tutorials and sample apps. It also has the FacebookSDK baked in.
- (Parse) FacebookSDK for dynamic friend search and picking.
- Glyphicons (glyphicons.com) for sweet (and free) icons.
