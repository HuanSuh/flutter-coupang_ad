# flutter_coupang_ad

쿠팡 파트너스에서 제공하는 광고 배너 뷰를 사용할 수 있도록 구현해 놓은 패키지입니다.

** 본 패키지는 쿠팡 파트너스에서 정식 제공하는 플러그인이 아닙니다.

** 쿠팡 파트너스에서 제공하는 광고에 대한 자세한 사항은 [쿠팡 파트너스](https://partners.coupang.com)에서 확인하세요.

<span style="color:blue">** 쿠팡 파트너스 가입 시 추천인 코드(**AF2693277**) 추가해주시면 축복 받으실거에요 :)</span>

## How to use

### Android
* Network security config 설정

`AndroidManifest.xml` 에 아래 속성 추가
```xml
<activity
    ...
    android:networkSecurityConfig="@xml/network_security_config"/>
```
`res/xml/network_security_config.xml` 생성하여 아래 내용 추가
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### iOS
`Info.plist`에 아래 내용 추가
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### Example
```dart
CoupangAdView(
    adId: '<AdID>',
    size: CoupangAdSize.banner,
    listener: (event, data) {
        switch (event) {
            case CoupangAdEvent.onAdClicked:
            break;
            case CoupangAdEvent.onAdLoaded:
            break;
            case CoupangAdEvent.onAdFailedToLoad:
            case CoupangAdEvent.onError:
            break;
        }
    },
),
```