##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

yum -y install wget
yum -y install tar
yum -y install rpm-build

cat << EOF > ~/.rpmmacros
%_topdir /root/rpmbuild
EOF

mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

pushd .

cd ~/rpmbuild/SOURCES
wget https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz

cat << EOF > ~/rpmbuild/SPECS/kibana.spec
Name:       kibana
Version:    4.2.0
Release:    1
Vendor:     elasticsearch
Summary:    GUN kibana x64
License:    Apache License, Version 2.0
Source:     kibana-4.2.0-linux-x64.tar.gz
Group:      System Enviroment/Daemons
URL:        http://www.elasticsearch.co/
Packager:   test@test.com
%description
kibana package

%prep
tar xf ../SOURCES/kibana-4.2.0-linux-x64.tar.gz

%install
cd ../BUILDROOT
mkdir -p ./kibana-4.2.0-1.x86_64/opt/kibana
cp -rf ../BUILD/kibana-4.2.0-linux-x64/* ./kibana-4.2.0-1.x86_64/opt/kibana

%clean
rm -rf ./kibana-4.2.0-linux-x64

%files
/opt/kibana/
EOF

cd ~
rpmbuild -bb rpmbuild/SPECS/kibana.spec

cp -rf rpmbuild/RPMS/* /var/cache/yum/

popd
