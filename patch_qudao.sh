#!/bin/bash


# Download Azur Lane
# Download Azur Lane
download_azurlane () {
    if [ ! -f "AzurLane.apk" ]; then
    # 这个链接是MUMU下载的,应该是9游,其他渠道自行修改直链
    #url="https://appdl-1-drcn.dbankcdn.com/dl/appdl/application/apk/7e/7e70bd9184a643ddaa4fc6cb9403817c/com.bilibili.blhx.huawei.2211101822.apk?maple=0&trackId=0&distOpEntity=HWSW"
    #这个链接是当乐网
    #url="https://res5.d.cn/4fea10ef16b7b0d5ea0f3a5ad9d3483753ab0106c1a0cdf1d67434fec122fbca9819ee365b07dae4ccbf47d02992f9785f5cc48955b4765f919e8a2ac789488082c80bca10f6617e.apk"
    # 使用curl命令下载apk文件
    #curl -o blhx.apk  $url
    
    url="https://github.com/liusj5257/azurlane_anti_name/releases/download/%E5%BD%93%E4%B9%90%E6%B8%A0%E9%81%93/dangle.AzurLane.patched.apk"
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
