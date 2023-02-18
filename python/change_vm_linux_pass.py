import subprocess, re, getpass
from pprint import pprint
from netmiko import (
    ConnectHandler,
    NetmikoTimeoutException,
    NetmikoAuthenticationException,
)

vm={}
vm_restr={}
vm_without_tools=[]

with open('list_vm.txt') as inp:
	regexp1=r'(\S+)[\s\{]+([\d\.]+)'
	regexp2=r'(by01-\S+)'
	for line in inp:
		match1=re.search(regexp1,line)
		match2=re.search(regexp2,line)
		if match1:
			if 'by01-r' not in match1.group(1) and 'by01-oum' not in match1.group(1) and 'by01-proxy' not in match1.group(1):
				if match1.group(2).split('.')[2] in ['46','47']:
					vm_restr[match1.group(1)]=match1.group(2)
				else:
					vm[match1.group(1)]=match1.group(2)
		elif match2:
			if 'by01-r' not in match2.group(1) and 'by01-oum' not in match2.group(1) and 'by01-proxy' not in match2.group(1):
				result = subprocess.run(['nslookup', match2.group(1)], stdout=subprocess.PIPE)
				regexp3=r'(\d+\.\d+\.\d+\.\d+)'
				ip_list=re.findall(regexp3,str(result))
				if len(ip_list) > 1:
					ip=ip_list[::-1][0]
					vm[match2.group(1)]=ip
				else:
					vm_without_tools.append(match2.group(1))

if(vm_without_tools):					
	print(f'\n VMware tools not install and dns-record not found for:')
	for vms in vm_without_tools:
		print(vms)

print('\nWork Nets:')			
pprint(vm)
print()
if vm_restr:
	print('Restricted Nets:')
	pprint(vm_restr)

print()
old_password = getpass.getpass(prompt='Enter old pass for root: ')
print()
new_password = getpass.getpass(prompt='Enter new pass for root: ')
new_password_check = getpass.getpass(prompt='Repeat new pass for root: ')
print()


def change_pass(vm):
    try:
        with ConnectHandler(**vm) as ssh:
            ssh.send_command(f'echo "root:{new_password}" | chpasswd')
        print(f'{name} ---  \x1b[6;30;42m' + 'Success!' + '\x1b[0m')
    except (NetmikoTimeoutException, NetmikoAuthenticationException) as error:
        print(f'Error with {name}:\n {error}')


if __name__ == "__main__":
	if new_password==new_password_check:
		print('\nStarting changing passwords...\n')
		for name,ip in vm.items():
		    linux = {
		        "device_type": "linux",
		        "ip": ip,
		        "username": "root",
		        "password": old_password,
		    }
		    change_pass(linux)
	else:
		print('\nDifferent passwords.Try again')