.. two dots create a comment. please leave this logo at the top of each of your rst files.

How to deploy while Jumphost cannot access internet
===================================================

If your Jumphost cannot access internet, don't worry, you can definitely deploy compass without
internet access.

You can download compass.iso first from OPNFV artifacts repository (http://artifacts.opnfv.org/,
search compass4nfv and select an appropriate ISO file) via wget or curl. Then copy the compass.iso
and the compass4nfv repository to your Jumphost and editor the ISO_URL to your local path.

After that you can deploy compass without internet access.
