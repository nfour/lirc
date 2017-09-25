# Build
coffee -c -o build src

# Copy over root files
rsync -am . ./build  --exclude '*/*' --include '*'