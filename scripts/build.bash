rm -rf build
mkdir build

# Build
coffee -c -o build src

# Copy over root files
rsync -am . ./build  --exclude '*/*' --include '*'

# Copy latent files from source, recursively
rsync -am ./src/* ./build --exclude '*.coffee'
