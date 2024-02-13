#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

# Dalvik fix
magiskpolicy --live "allow zygote dalvikcache_data_file file { execute }" \
    "allow system_server dalvikcache_data_file file { write }" \
    "allow system_server dalvikcache_data_file file { execute }"
