
`wget -O script.sh --no-check-certificate https://raw.githubusercontent.com/Nebulas0/Emby.CustomCssJS/main/src/script.sh && bash script.sh`

# EmbyCustomJavaScriptinCss

[English](README_EN.md)
**Beware of XSS risks. Any issues are at your own risk.**

**This plugin is based on mediabrowser.server.core 4.8.0.24-beta**

[Instructions](src/README.md)

Script (Paste the code into custom JavaScript or CSS)

[Telegram Channel](https://t.me/embycustomcssjs)

Bangmu plugins are currently unavailable for JavaScript or CSS.

Admin Page:

Scripts are available to all users, and users can choose to use them (mandatory).

  ![photo_2023-05-14_21-45-18](https://github.com/Shurelol/Emby.CustomCssJS/assets/16237201/b3890993-e5e7-497f-915c-8df75c53f64a)

---

## LSIO Docker Mod (自动安装)

对于在 [LinuxServer.io (LSIO) Docker 容器](https://github.com/linuxserver/docker-emby) 中运行的 Emby 服务器，可以使用 **LSIO Docker Mod** 在每次容器启动时自动安装插件 — 容器重建后无需手动干预。

### 工作原理

Mod 镜像 (`ghcr.io/nebulas0/emby-customcssjs:latest`) 包含：
- `Emby.CustomCssJS.dll` — 插件
- `CustomCssJS.js` — JS 模块
- `01-customcssjs.sh` — 每次容器启动时运行的初始化脚本

初始化脚本执行以下操作：
1. 将插件 DLL 复制到 `/config/plugins/`（持久化卷，幂等）
2. 将 JS 模块复制到 `/app/emby/system/dashboard-ui/modules/`
3. 修改 `app.js` 以加载模块（幂等，创建 `.bak` 备份）

### 使用方法

将 mod 添加到 `DOCKER_MODS` 环境变量中，如有现有 mod 则用 `|` 分隔：

```yaml
# 示例：Saltbox inventory (host_vars/localhost.yml)
clean_docker_envs_custom:
  DOCKER_MODS: "ghcr.io/darthshadow/linuxserver-mod-sqlite3-emby:2026.07.20-r2|ghcr.io/nebulas0/emby-customcssjs:latest"
```

```yaml
# 示例：docker-compose.yml
services:
  emby:
    image: lscr.io/linuxserver/emby:latest
    environment:
      - DOCKER_MODS=ghcr.io/nebulas0/emby-customcssjs:latest
    volumes:
      - /path/to/config:/config
```

添加 mod 后重新创建容器。插件将在启动时自动安装。查看容器日志中的 `[customcssjs]` 消息以确认。

### 手动安装（替代方案）

如果不使用 LSIO 容器，请使用[手动脚本](src/script.sh)：

```bash
wget -O script.sh --no-check-certificate https://raw.githubusercontent.com/Nebulas0/Emby.CustomCssJS/main/src/script.sh && bash script.sh
```

### 构建 Mod 镜像

Mod 镜像通过 GitHub Actions 在每次推送到 `main` 分支且 `mod/` 目录文件有变更时自动构建并发布到 GHCR。也可以在本地构建：

```bash
cd mod/
docker build -t ghcr.io/nebulas0/emby-customcssjs:latest .
docker push ghcr.io/nebulas0/emby-customcssjs:latest
```
