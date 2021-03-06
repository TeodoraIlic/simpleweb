#! /bin/bash
#url : https://github.com/GoogleCloudPlatform/nodejs-getting-started/blob/master/7-gce/gce/startup-script.sh
#	Copyright 2017, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START startup]
set -v

# Talk to the metadata server to get the project id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")

# Install logging monitor. The monitor will automatically pick up logs sent to
# syslog.
# [START logging]
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
service google-fluentd restart &
# [END logging]

# # Installing mongodb
# curl https://www.mongodb.org/static/pgp/server-4.0.asc | sudo apt-key add -
# echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
# apt-get update
# apt-get install -y mongodb-org
# cat > /etc/systemd/system/mongodb.service << EOF
# [Unit]
# Description=High-performance, schema-free document-oriented database
# After=network.target
# [Service]
# User=mongodb
# ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf
# [Install]
# WantedBy=multi-user.target
# EOF
# systemctl start mongodb
# systemctl enable mongodb

# Install dependencies from apt
apt-get install -yq ca-certificates git nodejs build-essential supervisor

# Install nodejs
mkdir /opt/nodejs
curl https://nodejs.org/dist/v9.9.0/node-v9.9.0-linux-x64.tar.gz | tar xvzf - -C /opt/nodejs --strip-components=1
ln -s /opt/nodejs/bin/node /usr/bin/node
ln -s /opt/nodejs/bin/npm /usr/bin/npm

# Get the application source code from the Google Cloud Repository.
# git requires $HOME and it's not set during the startup script.
export HOME=/root
git config --global credential.helper gcloud.sh
git clone https://source.cloud.google.com/my-exam-project-317517/simple-web-app  /opt/app
#[can be used, if needed]git clone https://github.com/PacktPublishing/Google-Cloud-Platform-Cookbook.git  /opt/app

# Install app dependencies
cd /opt/app/
npm install
cat >./.env << EOF
# COOKIE_SECRET=d44d5c45e7f8149aabc06a830dba5716b4bd952a639c82499954
# MONGODB_URI=mongodb://localhost:27017
EOF

# Create a nodeapp user. The application will run as this user.
useradd -m -d /home/nodeapp nodeapp
chown -R nodeapp:nodeapp /opt/app

# Configure supervisor to run the node app.
cat >/etc/supervisor/conf.d/node-app.conf << EOF
[program:nodeapp]
directory=/opt/app/Chapter01/mysite
command=npm start
autostart=true
autorestart=true
user=nodeapp
environment=HOME="/home/nodeapp",USER="nodeapp",NODE_ENV="production"
stdout_logfile=syslog
stderr_logfile=syslog
EOF

supervisorctl reread
supervisorctl update

# Application should now be running under supervisor
# [END startup]