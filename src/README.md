[English](README_EN.md)

### EMBY (Docker Server) Installation Instructions
- This solution is only valid for the `emby/embyserver:beta` image. Please test other images yourself.
- Log in to SSH with the root account and enter the following command for one-click installation:
```
wget -O script.sh --no-check-certificate https://raw.githubusercontent.com/Nebulas0/Emby.CustomCssJS/main/src/script.sh && bash script.sh
```
- After the server installation is complete, restart the container. A custom JS and CSS plugin will appear in the web console. Enter the custom JS and CSS code in the plugin to implement the corresponding functions.
- If the plugin does not appear, please check that the permissions of the mapped `config` folder are correct!

### Backend Modifications (Server)
- Copy `src\Emby.CustomCssJS.dll` to `programdata\plugins`

### Frontend Modifications (Server and Client)
- Server
- Copy `src\CustomCssJS.js` to `system\dashboard-ui\modules`
- Modify `system\dashboard-ui\app.js`
- In the `start()` function, add `list.push("./modules/CustomCssJS.js"),` before `Promise.all(list.map(loadPlugin))`

```
list.push("./modules/CustomCssJS.js"),
Promise.all(list.map(loadPlugin))
```
- Desktop Client
- Copy `src\CustomCssJS.js` to `electronapp\plugins`

- Mobile App (Android)
- Copy `src\CustomCssJS.js` to `assets\www\modules`
- Modify `assets\www\app.js`
- In the `start()` function, add `list.push("./modules/CustomCssJS.js"),` before `Promise.all(list.map(loadPlugin))`

```
list.push("./modules/CustomCssJS.js"),
Promise.all(list.map(loadPlugin))
```
- Modify `assets\www\native\android\apphost.js`
- Set `features.restrictedplugins` to `false`

```
features.restrictedplugins = false;
```
***
- Server-side script activation information is stored in `localStorage` under the keys `customcssServerConfig_${sercerID}` and `customjsServerConfig_${sercerID}`
- Local script activation information is stored in `localStorage`, with the keys `customcssLocalConfig` and `customjsLocalConfig`.
- If you are unable to access emby after enabling scripts, simply delete the corresponding data in `localStorage`.
