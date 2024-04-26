echo "download schema"
glass apollo download-schema -p AROptical -e production
echo "codegen"
glass apollo codegen -p AROptical
