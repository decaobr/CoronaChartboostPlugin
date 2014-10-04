When implementing Chartboost on Android make sure to add this to your AndroidManifest.xml:

<activity android:name="com.chartboost.sdk.CBImpressionActivity" 
          android:theme="@android:style/Theme.Translucent.NoTitleBar" 
          android:excludeFromRecents="true" />
