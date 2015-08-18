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

def get_packages_name_list(file_list):
    package_name_list = []

    for file in file_list:
        datas = yaml.load(open(file))
        for key, value in datas.items():
            if not key.endswith("packages") and not key.endswith("packages_noarch"):
                continue

            if not value:
                continue

            if value not in package_name_list:
                package_name_list += value

    return package_name_list

def generate_download_script(root, arch, tmpl):
    package_name_list = get_packages_name_list(get_file_list(root, arch))

    tmpl = Template(file=tmpl, searchList={'packages':package_name_list})

    with open('install_packages.sh', 'w') as f:
        f.write(tmpl.respond())

if __name__=='__main__':
    # generate_download_script('ansible', 'Debian', 'Debian.tmpl')
    generate_download_script(sys.argv[1], sys.argv[2], sys.argv[3])

