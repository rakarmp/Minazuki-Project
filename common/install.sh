#!/system/bin/sh

modpath="/data/adb/modules_update/MP"
moddir="/data/adb/modules/MP"

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

# ML UNLOCK GRAPHIC

# Find game
installed="$(pm list package | grep com.mobile.legends)"
if [[ ! -z "$installed" ]]; then
    playerprefs="/data/data/com.mobile.legends/shared_prefs/com.mobile.legends.v2.playerprefs.xml"
  
    # Up max hz to 144
    if [[ -f "$playerprefs" ]]; then
        if grep -q "HighFpsMode" "$playerprefs"; then
            sed -i -r 's/"HighFpsMode" value=".+"/"HighFpsMode" value="165"/' "$playerprefs"
        fi
    fi
  
    # Unlock super and ultra fps for game settings
    if [[ -f "$playerprefs" ]]; then
        if grep -q "HighFpsModeSee" "$playerprefs"; then
            sed -i -r 's/"HighFpsModeSee" value=".+"/"HighFpsModeSee" value="4"/' "$playerprefs"
        else
        fps1='<int name="HighFpsModeSee" value="4" />'
            sed -i "3i$fps1" "$playerprefs"
        fi
        if grep -q "HighFpsMode_new" "$playerprefs"; then
            sed -i -r 's/"HighFpsMode_new" value=".+"/"HighFpsMode_new" value="4"/' "$playerprefs"
        else
        fps2='<int name="HighFpsMode_new" value="4" />'
            sed -i "3i$fps2" "$playerprefs"
        fi
    fi
fi

# ----------------------
# Auto Single delay for A13
# ----------------------

android="$(getprop ro.build.version.release)"

[[ "$android" == "13" ]] && [[ "$android" != "true" ]] && {
    sed -i '/#debug.sf.latch_unsignaled/s/.*/debug.sf.latch_unsignaled=false/' "$modpath/system.prop"
    sed -i '/#debug.sf.auto_latch_unsignaled/s/.*/debug.sf.auto_latch_unsignaled=true/' "$modpath/system.prop"
}

# ----------------------
# Move scripts --> system and remove script folder
# ----------------------

cp -af "$modpath/script/automode.sh" "$modpath/system/bin/automode"
cp -af "$modpath/script/common.sh" "$modpath/system/bin/common"
cp -af "$modpath/script/menu.sh" "$modpath/system/bin/menu"
cp -af "$modpath/script/profiles.sh" "$modpath/system/bin/profiles"
cp -af "$modpath/script/tweaks.sh" "$modpath/system/bin/tweaks"

rm -rf "$modpath/script"

# ----------------------
# Cleam Unity shader cache
# ----------------------
cache="$(find /data/user_de -name *shaders_cache* -type f | grep code_cache)"

for clean in $cache; do
    rm -rf "$clean"
done

# End
