#!/bin/bash


# Download Azur Lane
# Download Azur Lane
download_azurlane () {
    if [ ! -f "AzurLane.apk" ]; then
    # 这个链接是MUMU下载的,应该是9游,其他渠道自行修改直链
    #url="https://appdl-1-drcn.dbankcdn.com/dl/appdl/application/apk/7e/7e70bd9184a643ddaa4fc6cb9403817c/com.bilibili.blhx.huawei.2211101822.apk?maple=0&trackId=0&distOpEntity=HWSW"
   
    # 使用curl命令下载apk文件
    #curl -o blhx.apk  $url
    
    url="https://url="https://appdl-1-drcn.dbankcdn.com/dl/appdl/application/apk/7e/7e70bd9184a643ddaa4fc6cb9403817c/com.bilibili.blhx.huawei.2211101822.apk?maple=0&trackId=0&distOpEntity=HWSW"
    curl -o blhx.apk -L $url
    
    fi
}

if [ ! -f "AzurLane.apk" ]; then
    echo "Get Azur Lane apk"
    download_azurlane
    mv *.apk "AzurLane.apk"
fi


echo "Decompile Azur Lane apk"
java -jar apktool.jar  -f d AzurLane.apk

echo "Copy libs"
cp -r libs/. AzurLane/lib/

echo "Patching Azur Lane"
oncreate=$(grep -n -m 1 'onCreate' AzurLane/smali/com/unity3d/player/UnityPlayerActivity.smali | sed  's/[0-9]*\:\(.*\)/\1/')
sed -ir "s#\($oncreate\)#.method private static native init(Landroid/content/Context;)V\n.end method\n\n\1#" AzurLane/smali/com/unity3d/player/UnityPlayerActivity.smali
sed -ir "s#\($oncreate\)#\1\n    const-string v0, \"Dev_Liu\"\n\n\    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V\n\n    invoke-static {p0}, Lcom/unity3d/player/UnityPlayerActivity;->init(Landroid/content/Context;)V\n#" AzurLane/smali/com/unity3d/player/UnityPlayerActivity.smali

echo "Build Patched Azur Lane apk"
java -jar apktool.jar  -f b AzurLane -o AzurLane.patched.apk

echo "Set Github Release version"

echo "PERSEUS_VERSION=$(echo Ship_Name)" >> $GITHUB_ENV

mkdir -p build
mv *.patched.apk ./build/
find . -name "*.apk" -print
