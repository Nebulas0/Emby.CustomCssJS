# EmbyCustomJS_Css

[中文](README.md)
- **Note the risk of cross-site scripting attacks**
- **This plugin is based on mediabrowser.server.core 4.8.0.24-beta**
- [How to use](src/README_EN.md)
- Scripts (Copy code to custom JavaScript or Css)
  - [Telegram Channel](https://t.me/embycustomcssjs)
  - OSD related code cannot be added by JavaScript and Css for the time being

- Admin page：
  - Provide scripts for All users, User can choose to use it or not unless the script is forced on

  ![photo_2023-05-14_21-45-18](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/274dc810-0fff-4d0c-9fe0-33cbba5fbf4f)

  

- User page：
  - Choose to use scripts provided by the admin or not
  - Add your own scripts which are stored in localStorage

  ![photo_2023-05-14_21-45-22](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/1d89c3d4-a393-448e-8c4a-78c9d63bde65)

- The script loading situation showed in the console

  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/0582e5a7-8539-4d4d-a360-7affe836f133)
  
- Code editor is provided

  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/b044e5e0-0bb9-4bc6-bdcc-ad764d1cb607)
  
  ![image](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/666c385c-457b-4949-ae32-25c8bf6621ae)

---

## LSIO Docker Mod (Automatic Installation)

For Emby servers running in a [LinuxServer.io (LSIO) Docker container](https://github.com/linuxserver/docker-emby), you can use the **LSIO Docker Mod** to automatically install the plugin on every container startup — no manual intervention needed after container recreation.

### How it works

The mod image (`ghcr.io/nebulas0/emby-customcssjs:latest`) contains:
- `Emby.CustomCssJS.dll` — the plugin
- `CustomCssJS.js` — the JS module
- `01-customcssjs.sh` — an init script that runs on every container start

The init script:
1. Copies the plugin DLL to `/config/plugins/` (persistent volume, idempotent)
2. Copies the JS module to `/app/emby/system/dashboard-ui/modules/`
3. Patches `app.js` to load the module (idempotent, creates a `.bak` backup)

### Usage

Add the mod to your `DOCKER_MODS` environment variable, separated by `|` if you have existing mods:

```yaml
# Example: Saltbox inventory (host_vars/localhost.yml)
clean_docker_envs_custom:
  DOCKER_MODS: "ghcr.io/darthshadow/linuxserver-mod-sqlite3-emby:2026.07.20-r2|ghcr.io/nebulas0/emby-customcssjs:latest"
```

```yaml
# Example: docker-compose.yml
services:
  emby:
    image: lscr.io/linuxserver/emby:latest
    environment:
      - DOCKER_MODS=ghcr.io/nebulas0/emby-customcssjs:latest
    volumes:
      - /path/to/config:/config
```

After adding the mod, recreate the container. The plugin will be installed automatically on startup. Check the container logs for `[customcssjs]` messages to confirm.

### Manual installation (alternative)

If you're not using an LSIO container, use the [manual script](src/script.sh):

```bash
wget -O script.sh --no-check-certificate https://raw.githubusercontent.com/Nebulas0/Emby.CustomCssJS/main/src/script.sh && bash script.sh
```

### Building the mod image

The mod is automatically built and published to GHCR via GitHub Actions on every push to `main` that changes files in the `mod/` directory. You can also build it locally:

```bash
cd mod/
docker build -t ghcr.io/nebulas0/emby-customcssjs:latest .
docker push ghcr.io/nebulas0/emby-customcssjs:latest
```
