#!/bin/bash

read -p "Please enter the Emby container name: " name  # 请输入 Emby 容器名称

echo "Emby-css installation in progress...
1. First, check the plugin
2. Then modify the homepage html"  # Emby-css安装中... 1.先检查插件 2.再修改首页html

# Use docker exec to check if the file exists  
if docker exec "$name" test -f "/config/plugins/Emby.CustomCssJS.dll"; then  
    echo "Plugin already installed, no need to install again!"  # 插件已安装过，无需重复安装！
else  
    # Install plugin
    wget -q --no-check-certificate https://raw.githubusercontent.com/Nebulas0/Emby.CustomCssJS/main/src/Emby.CustomCssJS.dll -O Emby.CustomCssJS.dll
    docker cp ./Emby.CustomCssJS.dll $name:/config/plugins/
    docker exec -it $name chmod 755 /config/plugins/Emby.CustomCssJS.dll
    echo "Plugin is installed for the first time!"  # 插件首次安装！
fi

# Download required file to the system
wget -q --no-check-certificate https://raw.githubusercontent.com/Nebulas0/Emby.CustomCssJS/main/src/CustomCssJS.js -O CustomCssJS.js  

# Copy file into the container
docker cp ./CustomCssJS.js $name:/app/emby/system/dashboard-ui/modules/

# Main installation function
function Installing() {  
	# Read file content    
	content=$(cat app.js)    
	# Define code to insert, without comma    
	code1='list.push("./modules/CustomCssJS.js")'    
	code2='Promise.all(list.map(loadPlugin))'      
	# Insert code before Promise.all(list.map(loadPlugin))    
	new_content=$(echo -e "${content//$code2/$code1,$code2}")  
	# Write new content to app.js    
	echo -e "$new_content" > app.js
	# Read file content again   
	content=$(cat app.js)  
	# Remove newline characters using tr  
	no_newline_content=$(echo "$content" | tr -d '\n')  
	# Write processed content back to app.js  
	echo -e "$no_newline_content" > app.js
	# Overwrite index.html in the container
	docker cp ./app.js $name:/app/emby/system/dashboard-ui/
}

# First, copy app.js from the container to local system
docker cp $name:/app/emby/system/dashboard-ui/app.js ./

# If replacement content is not present
count=$(grep -c "CustomCssJS.js" app.js)
if [ "$count" -eq 0 ]; then
    docker cp $name:/app/emby/system/dashboard-ui/app.js ./
    # Backup
    docker exec -it $name mkdir -p /app/emby/system/dashboard-ui/bak/
    docker cp ./app.js $name:/app/emby/system/dashboard-ui/bak/
    Installing
    echo "Success! Index.html installed for the first time!"  # 成功！Index.html 首次安装！
else
    docker cp $name:/app/emby/system/dashboard-ui/bak/app.js ./
    Installing
    echo "Success! Index.html has been modified again!"  # 成功！Index.html 已重新修改！
fi
