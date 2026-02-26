# Other guides
<!-- ----------------------------------------------------------------------- -->
## Pulsar editor
### Change UI/Tab/Tree fontsize
* Open `style.less` (**Edit** -> **Stylesheets**)
* Add the following lines ([source](https://github.com/atom/atom/issues/2530)):
```less
@font-size: 14px;
html, body, .tree-view, .tab-bar .tab {
  font-size: @font-size;
}
```

<!-- ----------------------------------------------------------------------- -->
## Other commands
* verify SHA fingerprint of an APK
```bash
keytool -printcert -jarfile file.apk
```

<!-- ----------------------------------------------------------------------- -->
