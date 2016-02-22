.. two dots create a comment. please leave this logo at the top of each of your rst files.

How to deploy without internet access
=====================================

If you have created your own ISO file(compass.iso), you realy could deploy without internet access,
edit "compass4nfv/deploy/conf/base.conf" file and assign item ISO_URL as your local ISO file path
(export ISO_URL=file:///compass4nfv/work/building/compass.iso).
Then execute "compass4nfv/deploy.sh" and Compass4nfv could deploy with local compass.iso without internet access.


Also you can download compass.iso first from OPNFV artifacts repository
(http://artifacts.opnfv.org/, search compass4nfv and select an appropriate ISO file) via wget or curl.
After this, edit "compass4nfv/deploy/conf/base.conf" file and assign item ISO_URL as your local ISO file path.
Then execute "compass4nfv/deploy.sh" and Compass4nfv could deploy with local compass.iso without internet access.



