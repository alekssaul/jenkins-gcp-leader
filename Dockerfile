# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
#
# jenkins-gcp-leader
#
# VERSION   0.0.2
FROM jenkins:1.651.3

MAINTAINER Evan Brown <evanbrown@google.com>

# Install plugins
USER root
COPY plugins.txt /usr/share/jenkins/plugins.txt
COPY workflow-version.txt /usr/share/jenkins/workflow-version.txt
RUN sed -i "s/@VERSION@/`cat /usr/share/jenkins/workflow-version.txt`/g" /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

RUN chown -R jenkins:jenkins /usr/share/jenkins

# Install gcloud
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN apt-get install -y -qq --no-install-recommends wget unzip python openssh-client \
  && apt-get clean \
  && cd /usr/local/bin \
  && wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip \
  && google-cloud-sdk/install.sh --usage-reporting=true --disable-installation-options \
  && google-cloud-sdk/bin/gcloud --quiet components update preview \
  && google-cloud-sdk/bin/gcloud --quiet config set component_manager/disable_update_check true
ENV PATH /usr/local/bin/google-cloud-sdk/bin:$PATH

# Setup entrypoint
COPY start.sh /usr/local/bin/start.sh
RUN chown jenkins /usr/local/bin/start.sh
USER jenkins
ENTRYPOINT ["/usr/local/bin/jenkins.sh"]
