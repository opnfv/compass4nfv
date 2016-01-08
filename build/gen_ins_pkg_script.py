import yaml, os, sys
from Cheetah.Template import Template

def get_file_list(root, arch):
    files = []

    dirs = os.listdir(os.path.join(root, 'roles'))

    for  dir in dirs:
        var_dir = os.path.join(root, 'roles', dir, 'vars')
        for name in ['main.yml', arch + r'.yml']:
            if os.path.exists(os.path.join(var_dir, name)):
                files.append(os.path.join(var_dir, name))

    return files

def get_packages_name_list(file_list, special_packages):
    package_name_list = []

    for file in file_list:
        datas = yaml.load(open(file))
        for key, value in datas.items():
            if key == "pip_packages":
                 continue

            if not key.endswith("packages") and not key.endswith("packages_noarch"):
                continue

            if not value:
                continue

            if not isinstance(value, list):
                value = [value]

            for i in value:
                if i in special_packages:
                    continue
                package_name_list.append(i)

    return package_name_list

def generate_download_script(root="", arch="", tmpl="", docker_tmpl="", default_packages="",
                             special_packages="", special_packages_script_dir="", special_packages_dir=""):
    package_name_list = get_packages_name_list(get_file_list(root, arch), special_packages) if root else []

    tmpl = Template(file=tmpl, searchList={'packages':package_name_list, 'default_packages':default_packages})
    with open('work/repo/install_packages.sh', 'w') as f:
        f.write(tmpl.respond())

    make_script = []
    for i in special_packages:
        name = 'make_' + i + '.sh'
        if os.path.exists(os.path.join(special_packages_script_dir, name)):
            make_script.append(name)

    searchList = {'scripts':make_script}
    if os.path.exists(special_packages_dir):
        special_packages_names=[]
        for i in os.listdir(special_packages_dir):
            if os.path.isfile(os.path.join(special_packages_dir, i)):
                special_packages_names.append(i)
        searchList.update({'spcial_packages':special_packages_names})

    Dockerfile=os.path.basename(docker_tmpl).split('.')[0]
    tmpl = Template(file=docker_tmpl, searchList=searchList)
    with open(os.path.join('work/repo', Dockerfile), 'w') as f:
        f.write(tmpl.respond())

if __name__=='__main__':
    # generate_download_script('ansible', 'Debian', 'Debian.tmpl')
    generate_download_script(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4],
                             sys.argv[5].split(' '), sys.argv[6].split(' '), sys.argv[7], sys.argv[8])

