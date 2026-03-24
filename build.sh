# Build the image
docker build -t lodash-legacy .

# Drop into the environment to test locally
docker run -it -v $(pwd):/lodash lodash-legacy

# Once inside, you can run tests manually:
source /usr/local/nvm/nvm.sh
nvm use 0.10
npm install
node test/test.js