.. two dots create a comment. please leave this logo at the top of each of your rst files.

How to deploy while jumphost cannot access internet
===================================================

If your jumphost cannot access internet, don't worry, you can definitely deploy compass without internet access.

1. Download compass.iso first from OPNFV artifacts repository (http://artifacts.opnfv.org/, search compass4nfv and select an appropriate ISO file) via wget or curl. 

2. Download the jumphost preparation package from the httpserver (http://205.177.226.237:9999/jh_env_package.tar.gz) via wget or curl. Attention that currentlt we only support ubuntu trusty as the jumphost os.

3. Clone the compass4nfv repository to your local place.

4. Copy the compass.iso, jh_env_package.tar.gz and the compass4nfv repository to your jumphost.

5. Export the local path of the compass.iso and jh_env_package.tar.gz on jumphost.

E.g.

.. code-block:: bash

    # ISO_URL is your iso's absolute path
    export ISO_URL=file:///home/compass/compass4nfv.iso
    export JHPKG_URL=file:///home/compass/jh_env_package.tar.gz

After those steps above you can deploy compass without internet access.
